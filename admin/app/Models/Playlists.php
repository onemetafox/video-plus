<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Playlists extends Model
{
    use HasFactory;

    protected $table = 'tbl_playlist';

    public $timestamps = false;
    
    protected $fillable = [
        'name',
        'user_id',
        'date'
    ];

    protected $casts = [
        'user_id' => 'integer',
    ];
}
