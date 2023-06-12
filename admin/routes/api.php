<?php

use App\Http\Controllers\ApiController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Artisan::call('migrate');
// Route::post('test', [ApiController::class, 'test']);
Route::post('user_signup', [ApiController::class, 'user_signup']);
Route::post('get_settings', [ApiController::class, 'get_settings']);
Route::post('get_system_settings', [ApiController::class, 'get_system_settings']);

Route::group(['middleware' => ['jwt.verify']], function () {
    Route::post('get_video', [ApiController::class, 'get_video']);
    Route::post('get_category', [ApiController::class, 'get_category']);

    Route::post('get_slider', [ApiController::class, 'get_slider']);

    Route::post('get_user_by_id', [ApiController::class, 'get_user_by_id']);
    Route::post('profile_update', [ApiController::class, 'profile_update']);
    Route::post('profile_image_update', [ApiController::class, 'profile_image_update']);
    Route::post('update_fcm_id', [ApiController::class, 'update_fcm_id']);

    Route::post('create_playlist', [ApiController::class, 'create_playlist']);
    Route::post('store_playlist_video', [ApiController::class, 'store_playlist_video']);
    Route::post('get_playlist_video', [ApiController::class, 'get_playlist_video']);
    Route::post('remove_playlist_or_video', [ApiController::class, 'remove_playlist_or_video']);

    Route::post('get_notification', [ApiController::class, 'get_notification']);

    Route::post('get_inapp_purchase_list', [ApiController::class, 'get_inapp_purchase_list']);
    Route::post('set_user_inapp_purchase', [ApiController::class, 'set_user_inapp_purchase']);

    Route::post('delete_user', [ApiController::class, 'delete_user']);
    Route::post('store_video_history', [ApiController::class, 'store_video_history']);
    Route::post('get_video_history', [ApiController::class, 'get_video_history']);
});
