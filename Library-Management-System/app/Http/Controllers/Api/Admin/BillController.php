<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Bill;
use App\Models\Notification;
use Exception;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BillController extends Controller
{
    /**
     * عرض كل الفواتير مع اسم الزبون والإجمالي
     */
    public function index(Request $request): JsonResponse
    {
        $bills = Bill::with(['customer.user:id,name,email'])
            ->when($request->search, function ($query, $search) {
                $query->whereHas('customer.user', function ($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                        ->orWhere('email', 'like', "%{$search}%");
                });
            })
            ->latest()
            ->paginate(15);

        return response()->json([
            'status' => 'success',
            'data'   => $bills,
        ]);
    }

    /**
     * عرض تفاصيل فاتورة محددة (للأدمن)
     */
    public function show($id): JsonResponse
    {
        $bill = Bill::with([
            'customer.user:id,name,email',
            'billDetails.book' => function ($q) {
                $q->withTrashed();
            },
        ])->findOrFail($id);

        return response()->json([
            'status' => 'success',
            'data'   => $bill,
        ]);
    }

    /**
     * حساب إجمالي الإيرادات مع إمكانية الفلترة بالتاريخ
     */
    public function totalRevenue(Request $request): JsonResponse
    {
        $query = Bill::where('status', 'paid');

        if ($request->filled('start_date')) {
            $query->whereDate('created_at', '>=', $request->start_date);
        }
        if ($request->filled('end_date')) {
            $query->whereDate('created_at', '<=', $request->end_date);
        }

        $total = $query->sum('total_price');

        return response()->json([
            'status'        => 'success',
            'total_revenue' => $total,
            'filters'       => [
                'start_date' => $request->start_date ?? 'all_time',
                'end_date'   => $request->end_date ?? 'all_time',
            ],
        ]);
    }

    /**
     * جلب طلبات التوصيل مع بيانات التواصل
     */
    public function deliveryRequests(Request $request): JsonResponse
    {
        $bills = Bill::with(['customer.user:id,name,email'])
            ->where('is_delivery', true)
            ->when($request->filled('status'), function ($query) use ($request) {
                return $query->where('delivery_status', $request->status);
            })
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return response()->json([
            'status' => 'success',
            'data'   => $bills,
        ]);
    }

    /**
     * تحديث حالة التوصيل وإشعار العميل فوراً
     */
    public function updateDeliveryStatus(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'delivery_status' => 'required|in:pending,preparing,out_for_delivery,delivered',
        ]);

        $bill = Bill::with('customer.user')->findOrFail($id);

        if (!$bill->is_delivery) {
            return response()->json([
                'status'  => 'error',
                'message' => 'هذه الفاتورة ليست طلب توصيل',
            ], 422);
        }

        $bill->update([
            'delivery_status' => $request->delivery_status,
        ]);

        if ($bill->customer?->user_id) {
            try {
                Notification::send(
                    $bill->customer->user_id,
                    'delivery_update',
                    'تحديث حالة الطلب 🚚',
                    "تم تحديث حالة توصيل طلبك رقم (#{$bill->id}) لتصبح الآن: " . $this->translateStatus($request->delivery_status),
                    [
                        'icon'          => 'delivery_truck',
                        'target_screen' => 'order_details',
                        'bill_id'       => $bill->id,
                    ]
                );
            } catch (Exception $e) {
                // تجاوز خطأ سيرفر الإشعارات حتى لا تتعطل الاستجابة
            }
        }

        return response()->json([
            'status'  => 'success',
            'message' => 'تم تحديث حالة التوصيل بنجاح',
            'data'    => $bill,
        ]);
    }

    private function translateStatus(string $status): string
    {
        $statuses = [
            'pending'          => 'قيد الانتظار',
            'preparing'        => 'جاري التجهيز',
            'out_for_delivery' => 'خرج للتوصيل',
            'delivered'        => 'تم التسليم بنجاح',
        ];

        return $statuses[$status] ?? $status;
    }

    /**
     * 1. عرض قائمة جميع فواتير الزبون المتصل
     */
    public function userBills(Request $request): JsonResponse
    {
        $customer = $request->user()?->customer;

        if (!$customer) {
            return response()->json([
                'status'  => 'error',
                'message' => 'سجل الزبون غير موجود',
            ], 404);
        }

        $bills = Bill::where('customer_id', $customer->id)
            ->withCount('billDetails')
            ->orderBy('created_at', 'desc')
            ->paginate(10);

        if ($bills->isEmpty()) {
            return response()->json([
                'status'  => 'success',
                'message' => 'لا توجد لديك فواتير حالياً. يمكنك البدء بالتسوق وإتمام الطلبات لتظهر فواتيرك هنا 🛍️',
                'data'    => [],
            ]);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $bills,
        ]);
    }

    /**
     * 2. عرض تفاصيل فاتورة محددة للزبون
     */
    public function userBillDetails(Request $request, $billId): JsonResponse
    {
        $customer = $request->user()?->customer;

        if (!$customer) {
            return response()->json([
                'status'  => 'error',
                'message' => 'سجل الزبون غير موجود',
            ], 404);
        }

        $locale = app()->getLocale();

        $bill = Bill::where('id', $billId)
            ->where('customer_id', $customer->id)
            ->with([
                'billDetails.book' => function ($query) {
                    $query->withTrashed()
                        ->select('id', 'title', 'cover')
                        ->with('translations');
                },
            ])
            ->first();

        if (!$bill) {
            return response()->json([
                'status'  => 'error',
                'message' => 'الفاتورة غير موجودة أو لا تملك صلاحية الوصول إليها',
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => [
                'bill_id'          => $bill->id,
                'total_amount'     => (string) ($bill->total_amount ?? $bill->total_price ?? '0.00'),
                'discount_amount'  => (string) ($bill->discount_amount ?? '0.00'),
                'delivery_fee'     => (string) ($bill->delivery_fee ?? '0.00'),
                'payment_method'   => $bill->payment_method,
                'status'           => $bill->status,
                'is_delivery'      => (bool) $bill->is_delivery,
                'delivery_status'  => $bill->delivery_status ?? 'not_applicable',
                'delivery_address' => $bill->delivery_address,
                'phone_number'     => $bill->phone_number,
                'created_at'       => $bill->created_at?->format('Y-m-d H:i'),

                'items' => $bill->billDetails->map(function ($detail) use ($locale) {
                    $book = $detail->book;

                    $translatedTitle = $book?->translations
                        ?->where('key', 'title')
                        ?->where('locale', $locale)
                        ?->first()?->value ?? $book?->title ?? 'كتاب غير متوفر';

                    $unitPrice = (float) ($detail->price ?? $detail->unit_price ?? 0);
                    $quantity  = (int) ($detail->quantity ?? 1);
                    $itemTotal = ((float) ($detail->total ?? 0) > 0) ? (float) $detail->total : ($unitPrice * $quantity);

                    $coverUrl = $book?->cover ? asset('storage/' . $book->cover) : null;

                    return [
                        'detail_id'  => $detail->id,
                        'book_id'    => $detail->book_id,
                        'book_title' => $translatedTitle,
                        'book_cover' => $coverUrl,
                        'unit_price' => number_format($unitPrice, 2, '.', ''),
                        'quantity'   => $quantity,
                        'total_item' => number_format($itemTotal, 2, '.', ''),

                        'type' => $detail->type ?? 'buy',

                        'borrow_details' => ($detail->type ?? '') === 'borrow' ? [
                            'borrow_date' => $detail->borrow_date,
                            'due_date'    => $detail->due_date,
                            'returned_at' => $detail->returned_at,
                        ] : null,
                    ];
                }),
            ],
        ]);
    }
}
