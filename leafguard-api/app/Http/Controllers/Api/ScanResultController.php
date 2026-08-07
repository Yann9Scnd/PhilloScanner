<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ScanResult;
use Illuminate\Http\Request;

class ScanResultController extends Controller
{
    /**
     * GET /api/scans
     */
    public function index()
    {
        return response()->json(ScanResult::orderByDesc('id')->get());
    }

    /**
     * GET /api/scans/latest
     */
    public function latest()
    {
        $scan = ScanResult::orderByDesc('id')->first();

        if (!$scan) {
            return response()->json(['message' => 'Belum ada hasil scan.'], 404);
        }

        return response()->json($scan);
    }

    /**
     * POST /api/scans
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'device_id' => 'required|string',
            'image_url' => 'required|string',
            'disease_name' => 'required|string',
            'scientific_name' => 'nullable|string',
            'severity' => 'required|string',
            'confidence' => 'required|integer|min:0|max:100',
            'timestamp' => 'nullable|string',
            'soil_moisture' => 'nullable|string',
            'ai_recommendations' => 'nullable|string',
        ]);

        $scan = ScanResult::create($validated);

        return response()->json($scan, 201);
    }
}
