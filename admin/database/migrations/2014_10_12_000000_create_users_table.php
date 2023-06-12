<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Schema;

class CreateUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->integer('is_subscribe')->default(0);            
            $table->string('firebase_id')->unique();
            $table->string('type');
            $table->string('role');
            $table->string('email');
            $table->string('mobile');
            $table->string('name');
            $table->longText('fcm_id');
            $table->string('profile');
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password')->nullable();
            $table->integer('status')->comment('0-deactive, 1-active');
            $table->date('date_registered');
            $table->date('inapp_exp_date')->nullable();
            $table->longText('api_token')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });

        DB::table('users')->insert([
            [
                'id' => 1,
                'firebase_id' => "admin",
                'type' => "",
                'role' => 'admin',
                'email' => 'admin@gmail.com',
                'mobile' => "",
                'name' => 'admin',
                'fcm_id' => "",
                'profile' => "",
                'password' => Hash::make('admin123'),
                'status' => 1,
                'date_registered' => '2022-05-06'
            ],
            [
                'id' => 2,
                'firebase_id' => "guest",
                'type' => "guest",
                'role' => 'guest',
                'email' => 'guest@gmail.com',
                'mobile' => "",
                'name' => 'guest',
                'fcm_id' => "",
                'profile' => "",
                'password' => "",
                'status' => 1,
                'date_registered' => '2022-05-06'
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
        Schema::dropIfExists('users');
    }
}
