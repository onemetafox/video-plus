<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTblSliderTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('tbl_slider', function (Blueprint $table) {
            $table->id();
            $table->string('image');
            $table->string('type')->comment('category or video');
            $table->integer('type_id');
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
        Schema::dropIfExists('tbl_slider');
    }
}
