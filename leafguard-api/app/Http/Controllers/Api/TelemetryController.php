<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SensorReading;
use Illuminate\Http\Request;

class TelemetryController extends Controller
{
    /**
     * POST /api/telemetry
     *
     * Endpoint khusus ESP32 (sketch yang di-generate aplikasi mobile).
     * Menerima JSON camelCase dari firmware lalu memetakannya ke kolom
     * snake_case tabel `sensor_readings`.
     *
     * Contoh payload firmware:
     * {
     *   "node": "Node 2 - Bedeng Timur Cabai",
     *   "soilMoisture": 58,
     *   "temp": 28.4,
     *   "humidity": 71.2,
     *   "lightIntensity": 18200,
     *   "waterTankLevel": 85,
     *   "soilPh": 6.3,
     *   "pumpStatus": "Standby"
     * }
     */
    public function store(Request $request)
    {
        $data = $request->all();

        $reading = SensorReading::create([
            'device_id' => $data['node'] ?? $data['device_id'] ?? 'ESP32 Node 2',
            'soil_moisture' => (string) ($data['soilMoisture'] ?? $data['soil_moisture'] ?? '0'),
            'temperature' => (string) ($data['temp'] ?? $data['temperature'] ?? '0'),
            'air_humidity' => (string) ($data['humidity'] ?? $data['air_humidity'] ?? '0'),
            'light_intensity' => (string) ($data['lightIntensity'] ?? $data['light_intensity'] ?? '0'),
            'water_tank_level' => (string) ($data['waterTankLevel'] ?? $data['water_tank_level'] ?? '0'),
            'soil_ph' => (string) ($data['soilPh'] ?? $data['soil_ph'] ?? '0'),
            'pump_status' => (string) ($data['pumpStatus'] ?? $data['pump_status'] ?? 'Standby'),
            'timestamp' => $data['timestamp'] ?? now()->toDateTimeString(),
        ]);

        return response()->json($reading, 201);
    }
}
