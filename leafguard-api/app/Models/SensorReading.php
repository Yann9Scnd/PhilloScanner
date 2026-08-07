<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SensorReading extends Model
{
    protected $fillable = [
        'device_id',
        'soil_moisture',
        'temperature',
        'pump_status',
        'timestamp',
    ];
}
