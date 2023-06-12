<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PlaylistData extends Model
{
    use HasFactory;

    protected $table = 'tbl_playlist_data';

    public $timestamps = false;
    
    protected $fillable = [
        'playlist_id',
        'user_id',
        'video_id',
        'date'
    ];

    protected $casts = [
        'playlist_id' => 'integer',
        'user_id' => 'integer',
        'video_id' => 'integer',
    ];
}
