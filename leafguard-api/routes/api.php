<?php

use Illuminate\Support\Facades\Route;

use App\Http\Controllers\Api\DiseaseController;
use App\Http\Controllers\Api\ScanResultController;
use App\Http\Controllers\Api\SensorReadingController;

// Dataset penyakit
Route::get('diseases', [DiseaseController::class, 'index']);

// Hasil scan ESP32-CAM
Route::get('scans', [ScanResultController::class, 'index']);
Route::get('scans/latest', [ScanResultController::class, 'latest']);
Route::post('scans', [ScanResultController::class, 'store']);

// Pembacaan sensor
Route::get('sensor-readings', [SensorReadingController::class, 'index']);
Route::post('sensor-readings', [SensorReadingController::class, 'store']);
