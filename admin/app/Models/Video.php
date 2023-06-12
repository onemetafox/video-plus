<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Storage;

class Video extends Model
{
    protected $table = 'tbl_video';

    public $timestamps = false;


    protected $fillable = [
        'category_id',
        'title',
        'video_type',
        'video_id',
        'duration',
        'image',
        'description',
        'type',
        'date',

    ];

    protected $casts = [
        'category_id' => 'integer',
        'video_type' => 'integer',
        'type' => 'integer',
    ];
}
