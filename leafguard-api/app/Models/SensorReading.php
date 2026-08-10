<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SensorReading extends Model
{
    protected $fillable = [
        'device_id',
        'soil_moisture',
        'temperature',
        'air_humidity',
        'light_intensity',
        'water_tank_level',
        'soil_ph',
        'pump_status',
        'timestamp',
    ];
}
