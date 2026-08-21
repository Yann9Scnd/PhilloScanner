<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ActuatorState;
use Illuminate\Http\Request;

class ActuatorController extends Controller
{
    /**
     * GET /api/actuators
     */
    public function index()
    {
        $existing = ActuatorState::latest('id')->first();

        $state = ActuatorState::updateOrCreate(
            $existing ? ['id' => $existing->id] : [],
            $existing ? [] : [
                'pump_auto_mode' => true,
                'pump_active' => false,
                'pesticide_active' => false,
                'laser_active' => false,
                'led_active' => false,
                'misting_active' => true,
                'grow_light_active' => false,
                'fan_active' => true,
            ]
        );

        return response()->json($state);
    }

    /**
     * POST /api/actuators
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'pump_auto_mode' => 'nullable|boolean',
            'pump_active' => 'nullable|boolean',
            'pesticide_active' => 'nullable|boolean',
            'laser_active' => 'nullable|boolean',
            'led_active' => 'nullable|boolean',
            'misting_active' => 'nullable|boolean',
            'grow_light_active' => 'nullable|boolean',
            'fan_active' => 'nullable|boolean',
        ]);

        $existing = ActuatorState::latest('id')->first();

        $state = ActuatorState::updateOrCreate(
            $existing ? ['id' => $existing->id] : [],
            $validated
        );

        return response()->json($state, $existing ? 200 : 201);
    }
}
