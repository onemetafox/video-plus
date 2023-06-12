<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTblVideoTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('tbl_video', function (Blueprint $table) {
            $table->id();
            $table->integer('category_id');
            $table->text('title');
            $table->string('video_id');
            $table->string('duration');
            $table->text('description');
            $table->integer('type')->comment('0-free, 1-paid');
            $table->date('date')->default('2022-11-10');

            $table->index(['category_id']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('tbl_video');
    }
}
