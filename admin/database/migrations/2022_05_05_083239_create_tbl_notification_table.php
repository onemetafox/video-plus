<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTblNotificationTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('tbl_notification', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('message');
            $table->string('image');
            $table->string('type')->comment('category or video');
            $table->integer('type_id');
            $table->string('users');
            $table->text('user_id');
            $table->date('date');

            $table->index(['type_id']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('tbl_notification');
    }
}
