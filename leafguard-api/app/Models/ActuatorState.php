<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ActuatorState extends Model
{
    protected $fillable = [
        'pump_auto_mode',
        'pump_active',
        'misting_active',
        'grow_light_active',
        'fan_active',
    ];

    protected $casts = [
        'pump_auto_mode' => 'boolean',
        'pump_active' => 'boolean',
        'misting_active' => 'boolean',
        'grow_light_active' => 'boolean',
        'fan_active' => 'boolean',
    ];
}
