<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Disease extends Model
{
    protected $fillable = [
        'name',
        'scientific_name',
        'category',
        'image_url',
        'description',
        'symptoms',
        'treatment_steps',
    ];
}
