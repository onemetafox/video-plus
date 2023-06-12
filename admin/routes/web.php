<?php

use App\Http\Controllers\CategoryController;
use App\Http\Controllers\HomeController;
use App\Http\Controllers\SettingController;
use App\Http\Controllers\SliderController;
use App\Http\Controllers\VideoController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\InAppController;
use App\Http\Controllers\SystemsController;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/

Auth::routes();
Route::get('clear-cache', function () {
    Artisan::call('cache:clear');
    Artisan::call('view:clear');
    Artisan::call('migarte');

    return redirect('/');
});

Route::get('/', [HomeController::class, 'login']);
Route::get('logout', [HomeController::class, 'logout']);
Route::get('settings/{type}', [SettingController::class, 'view_data']);

Route::group(['middleware' => ['auth']], function () {

    Route::get('dashboard', [HomeController::class, 'index']);
    Route::get('resetpassword', [HomeController::class, 'resetpassword']);

    Route::get('user', [HomeController::class, 'user']);
    Route::get('userList', [HomeController::class, 'userList']);

    Route::get('slider', [SliderController::class, 'index']);
    Route::get('sliderList', [SliderController::class, 'show']);

    Route::get('category', [CategoryController::class, 'index']);
    Route::get('categoryList', [CategoryController::class, 'show']);

    Route::get('video', [VideoController::class, 'index']);
    Route::get('videoList', [VideoController::class, 'show']);

    Route::get('notification', [NotificationController::class, 'index']);
    Route::get('notificationList', [NotificationController::class, 'show']);

    Route::get('inapp-purchase', [InAppController::class, 'index']);
    Route::get('inappPurchaseList', [InAppController::class, 'show']);

    Route::get('about-us', [SettingController::class, 'index']);
    Route::get('contact-us', [SettingController::class, 'index']);
    Route::get('privacy-policy', [SettingController::class, 'index']);
    Route::get('terms-conditions', [SettingController::class, 'index']);
    Route::get('notification-setting', [SettingController::class, 'index']);
    Route::get('system-settings', [SettingController::class, 'system_settings']);

    Route::get('system-update', [SystemsController::class, 'index']);

    Route::group(['middleware' => ['demomode']], function () {
        Route::get('checkPassword', [HomeController::class, 'checkPassword']);
        Route::post('changePassword', [HomeController::class, 'changePassword']);

        Route::post('multiple-delete', [HomeController::class, 'multiple_delete']);
        Route::post('user-update', [HomeController::class, 'updateUser']);

        Route::post('slider', [SliderController::class, 'store']);
        Route::post('slider-update', [SliderController::class, 'update']);
        Route::get('slider-delete', [SliderController::class, 'destroy']);

        Route::post('category', [CategoryController::class, 'store']);
        Route::post('category-update', [CategoryController::class, 'update']);
        Route::get('category-delete', [CategoryController::class, 'destroy']);

        Route::post('video', [VideoController::class, 'store']);
        Route::post('video-update', [VideoController::class, 'update']);
        Route::get('video-delete', [VideoController::class, 'destroy']);

        Route::post('notification', [NotificationController::class, 'store']);
        Route::get('notification-delete', [NotificationController::class, 'destroy']);

        Route::post('inapp-purchase', [InAppController::class, 'store']);
        Route::post('inapp-purchase-update', [InAppController::class, 'update']);
        Route::get('inapp-purchase-delete', [InAppController::class, 'destroy']);

        Route::post('settings', [SettingController::class, 'settings']);
        Route::post('setting-update', [SettingController::class, 'setting_update']);

        Route::post('system-update', [SystemsController::class, 'system_update']);
    });
});
