<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InAppUser extends Model
{
    use HasFactory;

    protected $table = 'tbl_inapp_user';

    public $timestamps = false;
    
    protected $fillable = [
        'user_id',
        'inapp_id',
        'date',
        'type',
        'name',
        'product_id',
        'days',
    ];

    protected $casts = [
        'user_id' => 'integer',
        'inapp_id' => 'integer',
    ];
}
