<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

use App\Http\Controllers\AuthController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\CustomerController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\TransactionController;
use App\Http\Controllers\ReadingController;
use App\Http\Controllers\BookRequestController;
use App\Http\Controllers\SettingController;

use App\Http\Controllers\Api\Admin\BookController;
use App\Http\Controllers\Api\Admin\CategoryController;
use App\Http\Controllers\Api\Admin\AuthorController;
use App\Http\Controllers\Api\Admin\BillController;
use App\Http\Controllers\Api\Admin\DashboardController;
use App\Http\Controllers\Api\Admin\TransactionController as AdminTransactionController;
use App\Http\Controllers\Api\Admin\UserController;
use App\Http\Controllers\Api\Admin\WaitingListController;

/*
|--------------------------------------------------------------------------
| 1. PUBLIC ROUTES — لا تحتاج تسجيل دخول
|--------------------------------------------------------------------------
*/

// --- المصادقة ---
Route::post('/register',     [AuthController::class, 'register']);     // تسجيل زبون جديد
Route::post('/login',        [AuthController::class, 'login']);        // تسجيل دخول زبون (برقم الهاتف)
Route::post('/admin/login',  [AuthController::class, 'adminLogin']);   // تسجيل دخول أدمن (بالإيميل)

// --- الكتب (عامة — بدون توكن) ---
Route::get('/books',              [BookController::class, 'index']);       // عرض كل الكتب مع دعم البحث والفلترة
Route::get('/books/top-borrowed', [BookController::class, 'topBorrowed']); // الكتب الأكثر استعارة
Route::get('/books/{id}',         [BookController::class, 'show']);        // تفاصيل كتاب محدد

// --- الإعدادات (عامة) ---
Route::get('/settings/footer', [SettingController::class, 'footer']);    // إعدادات الفوتر (اسم الموقع، تواصل، سوشيال)
Route::get('/settings/group',  [SettingController::class, 'getByGroup']); // جلب مجموعة إعدادات بالمفاتيح


/*
|--------------------------------------------------------------------------
| 2. PROTECTED ROUTES — تحتاج توكن (auth:sanctum)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {

    // --- بيانات المستخدم الحالي ---
    Route::get('/user', fn(Request $request) => $request->user()); // جلب بيانات المستخدم المسجل

    // --- المصادقة المحمية ---
    Route::post('/logout',          [AuthController::class, 'logout']);         // تسجيل الخروج وحذف التوكن
    Route::post('/change-password', [AuthController::class, 'changePassword']); // تغيير كلمة المرور

    // --- الملف الشخصي ---
    Route::get('/customer', [CustomerController::class, 'show']);   // عرض بيانات الزبون الحالي
    Route::put('/customer', [CustomerController::class, 'update']); // تحديث البيانات الشخصية (الاسم، الصورة، الهاتف...)

    /*
    |------------------------------------------------------------------
    | السلة — Cart
    |------------------------------------------------------------------
    | الزبون يضيف كتب للسلة (شراء أو استعارة) ثم يعمل Checkout
    |------------------------------------------------------------------
    */
    Route::prefix('cart')->group(function () {
        Route::get('/',                    [CartController::class, 'index']);      // عرض محتويات السلة الحالية
        Route::post('/add',                [CartController::class, 'addBook']);    // إضافة كتاب للسلة (type: buy أو borrow)
        Route::delete('/remove/{bookId}',  [CartController::class, 'removeBook']); // حذف كتاب محدد من السلة
        Route::delete('/clear',            [CartController::class, 'clear']);      // تفريغ السلة بالكامل
        Route::post('/checkout',           [CartController::class, 'checkout']);   // إتمام الطلب وإنشاء فاتورة ومعاملات
    });

    /*
    |------------------------------------------------------------------
    | المعاملات — Transactions
    |------------------------------------------------------------------
    */
    Route::prefix('transactions')->group(function () {
        Route::get('/my-history', [TransactionController::class, 'userHistory']); // سجل عمليات الزبون (شراء واستعارة)
    });

    /*
    |------------------------------------------------------------------
    | القراءة — Reading
    |------------------------------------------------------------------
    | تتبع تقدم الزبون في قراءة الكتب الرقمية
    |------------------------------------------------------------------
    */
    Route::post('/reading/update-progress', [ReadingController::class, 'updateProgress']); // تحديث الصفحة الحالية
    Route::get('/reading/current',          [ReadingController::class, 'currentReading']);  // قائمة الكتب التي يقرأها حالياً

    // --- تقييم كتاب (يشترط شراء أو استعارة وإرجاع مسبق) ---
    Route::post('/books/rate', [BookController::class, 'rateBook']); // تقييم كتاب من 1 إلى 5 نجوم

    /*
    |------------------------------------------------------------------
    | طلبات الكتب — Book Requests
    |------------------------------------------------------------------
    | الزبون يطلب كتاباً غير موجود في المكتبة
    |------------------------------------------------------------------
    */
    Route::get('/my-book-requests',        [BookRequestController::class, 'index']);   // عرض كل طلباتي
    Route::post('/my-book-requests',       [BookRequestController::class, 'store']);   // إرسال طلب كتاب جديد
    Route::get('/my-book-requests/{id}',   [BookRequestController::class, 'show']);    // تفاصيل طلب محدد
    Route::delete('/my-book-requests/{id}', [BookRequestController::class, 'destroy']); // إلغاء طلب (فقط إذا كان pending)

    /*
    |------------------------------------------------------------------
    | المفضلة — Favorites
    |------------------------------------------------------------------
    */
    Route::get('/favorites',         [FavoriteController::class, 'index']);  // عرض الكتب المفضلة
    Route::post('/favorites/toggle', [FavoriteController::class, 'toggle']); // إضافة أو حذف كتاب من المفضلة

    /*
    |------------------------------------------------------------------
    | الإشعارات — Notifications
    |------------------------------------------------------------------
    */
    Route::prefix('notifications')->group(function () {
        Route::get('/',             [NotificationController::class, 'index']);       // عرض كل إشعارات الزبون (paginated)
        Route::get('/unread-count', [NotificationController::class, 'unreadCount']); // عدد الإشعارات غير المقروءة
        Route::patch('/{id}/read',  [NotificationController::class, 'markAsRead']);  // تعيين إشعار كمقروء
    });


    /*
    |==========================================================================
    | 3. ADMIN ROUTES
    |==========================================================================
    */
    Route::prefix('admin')->middleware('admin')->group(function () {

        /*
        |----------------------------------------------------------------------
        | لوحة التحكم — Dashboard
        |----------------------------------------------------------------------
        */
        Route::get('/dashboard-stats',                    [DashboardController::class,       'index']);                // إحصائيات عامة (كتب، زبائن، إيرادات، استعارات)
        Route::get('/statistics/total-paid-orders',       [UserController::class,            'getTotalPaidOrdersCount']); // إجمالي الطلبات المدفوعة والإيرادات
        Route::get('/statistics/total-borrows',           [AdminTransactionController::class, 'getTotalBorrowsCount']); // إحصائيات الاستعارات (نشطة، منتهية، مرجعة)
        Route::get('/statistics/weekly-sales',            [AdminTransactionController::class, 'getWeeklySalesCount']); // مبيعات الأسبوع الحالي
        Route::get('/statistics/weekly-borrows',          [AdminTransactionController::class, 'getWeeklyBorrowsCount']); // استعارات الأسبوع الحالي
        Route::get('/statistics/top-selling-books',       [BookController::class,            'getTopSellingBooks']);   // أكثر 5 كتب مبيعاً

        /*
        |----------------------------------------------------------------------
        | إدارة الكتب — Books
        |----------------------------------------------------------------------
        */
        Route::apiResource('books', BookController::class);

        /*
        |----------------------------------------------------------------------
        | إدارة المؤلفين — Authors
        |----------------------------------------------------------------------
        */
        Route::apiResource('authors', AuthorController::class);

        /*
        |----------------------------------------------------------------------
        | إدارة المستخدمين — Users
        |----------------------------------------------------------------------
        */
        Route::apiResource('users', UserController::class)->only(['index', 'show', 'destroy']);
        Route::get('/users/{id}/full-details', [UserController::class, 'getFullUserDetails']); // التقرير المالي الكامل للزبون

        /*
        |----------------------------------------------------------------------
        | إدارة التصنيفات — Categories
        |----------------------------------------------------------------------
        */
        Route::apiResource('categories', CategoryController::class)->except(['show']);

        /*
        |----------------------------------------------------------------------
        | قائمة الانتظار — Waiting List
        |----------------------------------------------------------------------
        */
        Route::get('/waiting-list',        [WaitingListController::class, 'index']);           // عرض قائمة الانتظار (فلترة بـ book_id)
        Route::delete('/waiting-list/{id}', [WaitingListController::class, 'destroy']);          // حذف طلب من قائمة الانتظار
        Route::get('/waiting-list/top',    [WaitingListController::class, 'topWaitingBooks']); // أكثر 5 كتب طلباً في قائمة الانتظار

        /*
        |----------------------------------------------------------------------
        | إدارة المعاملات — Transactions (Admin)
        |----------------------------------------------------------------------
        */
        Route::get('/transactions',              [AdminTransactionController::class, 'index']);           // عرض كل المعاملات مع فلترة بالحالة
        Route::get('/transactions/top-borrowed', [AdminTransactionController::class, 'topBorrowedBooks']); // أكثر 5 كتب استعارة تاريخياً
        Route::post('/transactions/checkout',    [TransactionController::class,      'store']);            // إنشاء معاملة يدوية (استعارة أو شراء)
        Route::post('/transactions/{id}/return', [TransactionController::class,      'returnBook']);       // تسجيل إرجاع كتاب (مع حساب الغرامة)
        Route::get('/transactions/late',         [TransactionController::class,      'getLateTransactions']); // جلب الاستعارات المتأخرة وإرسال تنبيهات

        /*
        |----------------------------------------------------------------------
        | إدارة الفواتير — Bills
        |----------------------------------------------------------------------
        */
        Route::get('/bills',                          [BillController::class, 'index']);               // عرض كل الفواتير
        Route::get('/bills/total-revenue',            [BillController::class, 'totalRevenue']);         // إجمالي الإيرادات من الفواتير المدفوعة
        Route::get('/bills/{id}',                     [BillController::class, 'show']);                 // تفاصيل فاتورة محددة
        Route::get('/delivery-requests',              [BillController::class, 'deliveryRequests']);     // طلبات التوصيل مع فلترة بالحالة
        Route::patch('/bills/{id}/delivery-status',   [BillController::class, 'updateDeliveryStatus']); // تحديث حالة التوصيل (pending/preparing/out_for_delivery/delivered)

        /*
        |----------------------------------------------------------------------
        | طلبات الكتب — Book Requests (Admin)
        |----------------------------------------------------------------------
        */
        Route::put('/book-requests/{id}/status', [BookRequestController::class, 'updateStatus']); // قبول أو رفض طلب كتاب مع إشعار الزبون

        /*
        |----------------------------------------------------------------------
        | الإعدادات — Settings (Admin)
        |----------------------------------------------------------------------
        */
        Route::get('/settings',         [SettingController::class, 'index']);  // عرض كل إعدادات النظام
        Route::post('/settings/update', [SettingController::class, 'update']); // تحديث إعدادات متعددة دفعة وحدة

        /*
        |----------------------------------------------------------------------
        | الإشعارات — Notifications (Admin)
        |----------------------------------------------------------------------
        */
        Route::post('/notifications/global', [NotificationController::class, 'sendGlobalNotification']); // إرسال إشعار جماعي لكل المستخدمين
    });
});
