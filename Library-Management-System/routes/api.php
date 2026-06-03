<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;



use App\Http\Controllers\NotificationController;

use App\Http\Controllers\TransactionController;
use App\Http\Controllers\ReadingController;

// ==================== استيراد متحكمات الآدمن والكتب المشتركة ====================
use App\Http\Controllers\Api\Admin\BookController;
use App\Http\Controllers\Api\Admin\CategoryController;
use App\Http\Controllers\Api\Admin\AuthorController;
use App\Http\Controllers\Api\Admin\BillController;
use App\Http\Controllers\Api\Admin\DashboardController;
use App\Http\Controllers\Api\Admin\TransactionController as AdminTransactionController;
use App\Http\Controllers\Api\Admin\UserController;
use App\Http\Controllers\Api\Admin\WaitingListController;

// ==================== استيراد متحكمات مصطفى (المحدثة والموحدة) ====================
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\CustomerController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// ==================== 1. Public Routes (الروابط العامة للجميع) ====================

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);
Route::post('/admin/login', [AuthController::class, 'adminLogin']);
// راوتات الكتب العامة (ملاحظة مصطفى: ترتيب top-borrowed قبل {id} حرج جداً هنا)
Route::get('/books/top-borrowed', [BookController::class, 'topBorrowed']);
Route::get('/books',              [BookController::class, 'index']);
Route::get('/books/{id}',         [BookController::class, 'show']);


// ==================== 2. Protected Routes (الروابط المحمية للمسجلين) ====================

Route::middleware('auth:sanctum')->group(function () {

    // --- بيانات المستخدم الحالي ---
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // --- العمليات الحساسة (مصطفى) ---
    Route::post('/logout',          [AuthController::class, 'logout']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);

    // --- الملف الشخصي للعميل (مصطفى) ---
    Route::get('/customer', [CustomerController::class, 'show']);
    Route::put('/customer', [CustomerController::class, 'update']);

    // --- عربة التسوق والسلة (مصطفى) ---
    Route::get('/cart',                  [CartController::class, 'index']);
    Route::post('/cart/add',             [CartController::class, 'addBook']);
    Route::delete('/cart/remove/{book}', [CartController::class, 'removeBook']);
    Route::delete('/cart/clear',         [CartController::class, 'clear']);
    Route::post('/cart/checkout',        [CartController::class, 'checkout']);

    // --- التقييمات (مصطفى) ---
    Route::post('/books/rate', [BookController::class, 'rateBook']);


    Route::post('/reading/update-progress', [ReadingController::class, 'updateProgress']);


    Route::prefix('transactions')->group(function () {
        Route::post('/borrow', [TransactionController::class, 'borrowBook']);
        Route::post('/checkout', [TransactionController::class, 'store']);
        Route::post('/{id}/return', [TransactionController::class, 'returnBook']);
        Route::get('/late', [TransactionController::class, 'getLateTransactions']);
    });

    Route::get('/users/{id}/transactions', [TransactionController::class, 'userHistory']);


    Route::post('/admin/notifications/global', [NotificationController::class, 'sendGlobalNotification']);

    Route::prefix('notifications')->group(function () {
        Route::get('/', [NotificationController::class, 'index']);
        Route::get('/unread-count', [NotificationController::class, 'unreadCount']);
        Route::patch('/mark-as-read', [NotificationController::class, 'markAsRead']);
    });





    // ==================== 3. Admin Routes (لوحة التحكم للآدمن فقط) ====================
    Route::prefix('admin')->middleware('admin')->group(function () {

        // إحصائيات لوحة التحكم
        Route::get('/dashboard-stats', [DashboardController::class, 'index']);

        // إدارة الكتب والمؤلفين والتصنيفات (CRUD القياسي بدون أقواس مصفوفة تسبب مشاكل)
        Route::apiResource('books', BookController::class);
        Route::post('/categories', [CategoryController::class, 'store']);
        Route::get('/categories/list', [CategoryController::class, 'list']);
        Route::apiResource('authors', AuthorController::class);

        // إدارة مستخدمي النظام
        Route::apiResource('users', UserController::class);

        // قوائم الانتظار للكتب المستعارة
        Route::get('/waiting-list', [WaitingListController::class, 'index']);
        Route::delete('/waiting-list/{id}', [WaitingListController::class, 'destroy']);

        // تقارير الاستعارات للآدمن
        Route::get('/transactions', [AdminTransactionController::class, 'index']);
        Route::get('/transactions/top-borrowed', [AdminTransactionController::class, 'topBorrowedBooks']);
        Route::get('/transactions/{id}', [AdminTransactionController::class, 'show']);


        // الفواتير والأرباح والمالية
        Route::get('/bills', [BillController::class, 'index']);
        Route::get('/bills/total-revenue', [BillController::class, 'totalRevenue']);
        Route::get('/bills/{id}', [BillController::class, 'show']);


        // تفاصيل وإحصائيات متقدمة للمشتركين والتقارير الأسبوعية
        Route::get('users/{id}/full-details', [UserController::class, 'getFullUserDetails']);
        Route::get('statistics/total-paid-orders', [UserController::class, 'getTotalPaidOrdersCount']);
        Route::get('statistics/total-borrows', [AdminTransactionController::class, 'getTotalBorrowsCount']);
        Route::get('statistics/weekly-sales', [AdminTransactionController::class, 'getWeeklySalesCount']);
        Route::get('statistics/weekly-borrows', [AdminTransactionController::class, 'getWeeklyBorrowsCount']);
        Route::get('statistics/top-selling-books', [BookController::class, 'getTopSellingBooks']);

        Route::get('delivery-requests', [BillController::class, 'deliveryRequests']);
        Route::patch('bills/{id}/delivery-status', [BillController::class, 'updateDeliveryStatus']);
    });
});
