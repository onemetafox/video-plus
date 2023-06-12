<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InAppPurchase extends Model
{
    use HasFactory;

    protected $table = 'tbl_inapp_list';

    public $timestamps = false;
    
    protected $fillable = [
        'type',
        'name',
        'product_id',
        'days',
        'status'
    ];

    protected $casts = [
        'status' => 'integer',
    ];
}
