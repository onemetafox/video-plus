<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTblInappListTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('tbl_inapp_list', function (Blueprint $table) {
            $table->id();
            $table->string('type')->comment('ios, android');
            $table->string('name');
            $table->string('product_id');
            $table->string('days');
            $table->integer('status')->comment('0-deactive, 1-active');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('tbl_inapp_list');
    }
}
