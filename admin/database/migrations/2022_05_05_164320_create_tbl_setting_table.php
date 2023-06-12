<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class CreateTblSettingTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('tbl_setting', function (Blueprint $table) {
            $table->id();
            $table->text('type');
            $table->longText('message');
        });

        DB::table('tbl_setting')->insert([
            [
                'type' => 'app_name',
                'message' => 'Video Plus',
            ],
            [
                'type' => 'theme_color',
                'message' => '#1eabff',
            ],
            [
                'type' => 'full_logo',
                'message' => 'logo.svg',
            ],
            [
                'type' => 'half_logo',
                'message' => 'favicon.png',
            ],
            [
                'type' => 'system_version',
                'message' => '1.0.0',
            ],
            [
                'type' => 'app_version_android',
                'message' => '0.1',
            ],
            [
                'type' => 'app_version_ios',
                'message' => '0.1',
            ],
            [
                'type' => 'force_update',
                'message' => '0',
            ],
            [
                'type' => 'app_maintenance',
                'message' => '0',
            ],
            [
                'type' => 'about_us',
                'message' => '<h5>About Us <small>About content for App</small></h5>',
            ],
            [
                'type' => 'contact_us',
                'message' => '<h5>Contact Us <small>Contact for App Usage</small></h5>',
            ],
            [
                'type' => 'privacy_policy',
                'message' => '<h5>Privacy Policy <small>Policy for App Usage</small></h5>',
            ],
            [
                'type' => 'terms_conditions',
                'message' => '<h5>Terms Conditions <small>Terms for App Usage</small></h5>',
            ],
            [
                'type' => 'notification_setting',
                'message' => '',
            ]
        ]);
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('tbl_setting');
    }
}
