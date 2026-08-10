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
        $state = ActuatorState::latest()->first();
        if (!$state) {
            $state = ActuatorState::create([
                'pump_auto_mode' => true,
                'pump_active' => false,
                'misting_active' => true,
                'grow_light_active' => false,
                'fan_active' => true,
            ]);
        }
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
            'misting_active' => 'nullable|boolean',
            'grow_light_active' => 'nullable|boolean',
            'fan_active' => 'nullable|boolean',
        ]);

        $state = ActuatorState::create($validated);
        return response()->json($state, 201);
    }
}
