<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTblInappUserTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('tbl_inapp_user', function (Blueprint $table) {
            $table->id();
            $table->integer('user_id');
            $table->integer('inapp_id');
            $table->date('date');
            $table->string('type')->comment('ios, android');
            $table->string('name');
            $table->string('product_id');
            $table->string('days');

            $table->index(['user_id','inapp_id']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('tbl_inapp_user');
    }
}
