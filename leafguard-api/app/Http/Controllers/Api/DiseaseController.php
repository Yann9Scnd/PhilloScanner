<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Disease;
use Illuminate\Http\Request;

class DiseaseController extends Controller
{
    /**
     * GET /api/diseases?category=Jamur
     */
    public function index(Request $request)
    {
        $query = Disease::query();

        if ($request->filled('category')) {
            $query->where('category', $request->query('category'));
        }

        return response()->json($query->orderBy('id')->get());
    }
}
