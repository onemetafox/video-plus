<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class VideoHistory extends Model
{
    use HasFactory;
    protected $table = 'tbl_video_history';



    protected $fillable = [
        'video_id',
        'duration',
        'user_id',
    ];

    protected $casts = [
        'user_id' => 'integer',
    ];
}
