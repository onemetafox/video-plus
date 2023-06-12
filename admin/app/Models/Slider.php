<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Slider extends Model
{
    use HasFactory;

    protected $table = 'tbl_slider';

    public $timestamps = false;
    
    protected $fillable = [
        'image',
        'type',
        'type_id',
        'date'
    ];

    protected $casts = [
        'type_id' => 'integer',
    ];

}
