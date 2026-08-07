<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SensorReading;
use Illuminate\Http\Request;

class SensorReadingController extends Controller
{
    /**
     * GET /api/sensor-readings
     */
    public function index()
    {
        return response()->json(SensorReading::orderByDesc('id')->get());
    }

    /**
     * POST /api/sensor-readings
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'device_id' => 'required|string',
            'soil_moisture' => 'nullable|string',
            'temperature' => 'nullable|string',
            'pump_status' => 'nullable|string',
            'timestamp' => 'nullable|string',
        ]);

        $reading = SensorReading::create($validated);

        return response()->json($reading, 201);
    }
}
