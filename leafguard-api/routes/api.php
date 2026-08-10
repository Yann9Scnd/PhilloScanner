<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\ActuatorController;
use App\Http\Controllers\Api\DiseaseController;
use App\Http\Controllers\Api\ScanResultController;
use App\Http\Controllers\Api\SensorReadingController;
use App\Http\Controllers\Api\TelemetryController;

// Dataset penyakit
Route::get('diseases', [DiseaseController::class, 'index']);

// Hasil scan ESP32-CAM
Route::get('scans', [ScanResultController::class, 'index']);
Route::get('scans/latest', [ScanResultController::class, 'latest']);
Route::post('scans', [ScanResultController::class, 'store']);

// Pembacaan sensor
Route::get('sensor-readings', [SensorReadingController::class, 'index']);
Route::get('sensor-readings/latest', [SensorReadingController::class, 'latest']);
Route::post('sensor-readings', [SensorReadingController::class, 'store']);

// Telemetri ESP32 (sketch yang di-generate aplikasi) -> sensor_readings
Route::post('telemetry', [TelemetryController::class, 'store']);

// Sakelar Aktuator
Route::get('actuators', [ActuatorController::class, 'index']);
Route::post('actuators', [ActuatorController::class, 'store']);
