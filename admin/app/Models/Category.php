<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Category extends Model
{
    use HasFactory;

    protected $table = 'tbl_category';

    public $timestamps = false;
    
    protected $fillable = [
        'category_name',
        'image',
        'description',
        'sequence',
        'date'
    ];

    protected $casts = [
        'sequence' => 'integer',
    ];
}
