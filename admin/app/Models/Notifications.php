<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notifications extends Model
{
    use HasFactory;

    protected $table = 'tbl_notification';

    public $timestamps = false;
    
    protected $fillable = [
        'title',
        'message',
        'image',
        'type',
        'type_id',
        'users',
        'user_id',
        'date'
    ];

    protected $casts = [
        'type_id' => 'integer',
    ];
}
