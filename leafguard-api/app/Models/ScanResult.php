<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ScanResult extends Model
{
    protected $fillable = [
        'device_id',
        'image_url',
        'disease_name',
        'scientific_name',
        'severity',
        'confidence',
        'timestamp',
        'soil_moisture',
        'ai_recommendations',
    ];

    protected $casts = [
        'confidence' => 'integer',
    ];
}
