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
     * GET /api/sensor-readings/latest
     */
    public function latest()
    {
        $reading = SensorReading::orderByDesc('id')->first();
        if (!$reading) {
            return response()->json(['message' => 'Belum ada pembacaan sensor.'], 404);
        }
        return response()->json($reading);
    }

    /**
     * POST /api/sensor-readings
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'device_id' => 'nullable|string',
            'soil_moisture' => 'nullable|string',
            'temperature' => 'nullable|string',
            'air_humidity' => 'nullable|string',
            'light_intensity' => 'nullable|string',
            'water_tank_level' => 'nullable|string',
            'soil_ph' => 'nullable|string',
            'battery_level' => 'nullable|string',
            'leaf_distance' => 'nullable|string',
            'pump_status' => 'nullable|string',
            'timestamp' => 'nullable|string',
        ]);

        $reading = SensorReading::create($validated);

        return response()->json($reading, 201);
    }
}
