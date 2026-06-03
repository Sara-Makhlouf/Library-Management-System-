<?php

namespace App\Http\Controllers;

use App\Models\Book;
use App\Models\Cart;
use App\Models\CartDetail;
use App\Models\Bill;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $customerId = $request->user()->customer_id ?? $request->user()->id;
        $cart = Cart::with(['details.book'])->where('customer_id', $customerId)->first();

        return response()->json([
            'status' => 'success',
            'data' => $cart ?? ['details' => [], 'total_price' => 0]
        ]);
    }

    public function addBook(Request $request)
    {
        $request->validate([
            'book_id' => ['required', 'exists:books,id'],
            'type'    => ['required', 'in:buy,borrow'],
        ]);

        $customerId = $request->user()->customer_id ?? $request->user()->id;
        $book = Book::findOrFail($request->book_id);

        if ($book->stock <= 0) return response()->json(['status' => 'error', 'message' => 'الكتاب غير متوفر'], 422);

        $cart = Cart::firstOrCreate(['customer_id' => $customerId], ['total_price' => 0]);

        if ($cart->details()->where('book_id', $book->id)->exists()) {
            return response()->json(['status' => 'error', 'message' => 'الكتاب موجود مسبقاً'], 422);
        }

        $cart->details()->create([
            'book_id'  => $book->id,
            'price'    => $request->type === 'buy' ? $book->sale_price : $book->price,
            'type'     => $request->type,
            'due_at'   => $request->type === 'borrow' ? now()->addDays(7) : null,
        ]);

        $cart->update(['total_price' => $cart->details()->sum('price')]);

        return response()->json(['status' => 'success', 'message' => 'تمت الإضافة', 'data' => $cart->load('details.book')]);
    }

    public function removeBook(Request $request, $bookId)
    {
        $customerId = $request->user()->customer_id ?? $request->user()->id;
        $cart = Cart::where('customer_id', $customerId)->first();

        if ($cart) {
            $cart->details()->where('book_id', $bookId)->delete();
            $cart->update(['total_price' => $cart->details()->sum('price')]);
            return response()->json(['status' => 'success', 'message' => 'تم حذف الكتاب']);
        }
        return response()->json(['status' => 'error', 'message' => 'السلة غير موجودة'], 404);
    }

    public function clear(Request $request)
    {
        $customerId = $request->user()->customer_id ?? $request->user()->id;
        $cart = Cart::where('customer_id', $customerId)->first();

        if ($cart) {
            $cart->details()->delete();
            $cart->update(['total_price' => 0]);
        }
        return response()->json(['status' => 'success', 'message' => 'تم تفريغ السلة']);
    }

    public function checkout(Request $request)
    {
        $request->validate([
            'payment_method'   => ['required', 'in:cash,online'],
            'is_delivery'      => ['required', 'boolean'],
        ]);

        $customerId = $request->user()->customer_id ?? $request->user()->id;
        $cart = Cart::with('details.book')->where('customer_id', $customerId)->first();

        if (!$cart || $cart->details->isEmpty()) return response()->json(['status' => 'error', 'message' => 'السلة فارغة'], 422);

        $bill = DB::transaction(function () use ($cart, $customerId, $request) {
            $deliveryFee = $request->is_delivery ? 5000 : 0;
            $bill = Bill::create([
                'customer_id'      => $customerId,
                'total_price'      => $cart->total_price + $deliveryFee,
                'payment_method'   => $request->payment_method,
                'status'           => 'paid',
            ]);

            foreach ($cart->details as $detail) {
                Transaction::create([
                    'bill_id'      => $bill->id,
                    'book_id'      => $detail->book_id,
                    'price'        => $detail->price,
                    'type'         => $detail->type,
                    'delivered_at' => now(),
                    'status'       => ($detail->type === 'buy') ? 'sold' : 'received',
                ]);
            }

            $cart->details()->delete();
            $cart->update(['total_price' => 0]);
            return $bill;
        });

        return response()->json(['status' => 'success', 'message' => 'تمت العملية بنجاح', 'data' => $bill]);
    }
}