<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateTblPlaylistDataTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('tbl_playlist_data', function (Blueprint $table) {
            $table->id();
            $table->integer('playlist_id');
            $table->integer('user_id');
            $table->integer('video_id');
            $table->date('date');

            $table->index(['user_id','playlist_id']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('tbl_playlist_data');
    }
}
