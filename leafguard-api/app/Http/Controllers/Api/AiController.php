<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class AiController extends Controller
{
    public function analyze(Request $request)
    {
        $request->validate([
            'image' => 'required|string',
            'device_source' => 'nullable|string',
            'sector' => 'nullable|string',
            'temperature' => 'nullable|numeric',
            'soil_moisture' => 'nullable|string',
        ]);

        $provider = config('ai.provider', 'gemini');
        $apiKey = $provider === 'openai'
            ? config('ai.openai_key', '')
            : config('ai.gemini_key', '');

        if (empty($apiKey)) {
            return response()->json([
                'error' => 'API Key belum dikonfigurasi di server.',
            ], 500);
        }

        $prompt = $this->getPrompt();

        try {
            if ($provider === 'openai') {
                $result = $this->callOpenAI($apiKey, $request->image, $prompt);
            } else {
                $result = $this->callGemini($apiKey, $request->image, $prompt);
            }
            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Gagal menganalisis: ' . $e->getMessage(),
            ], 500);
        }
    }

    private function getPrompt(): string
    {
        return <<<'PROMPT'
Kamu adalah ahli patologi tanaman cabai (Capsicum annuum).
Tugas: analisis foto daun cabai dan identifikasi penyakitnya.

Kamu WAJIB merespons HANYA dalam format JSON valid (tanpa markdown, tanpa code block) seperti ini:
{
  "disease_name": "Nama penyakit dalam Bahasa Indonesia",
  "scientific_name": "Nama latin penyakit",
  "severity": "Rendah atau Sedang atau Tinggi",
  "confidence": 85,
  "recommendations": [
    "Rekomendasi pertama yang spesifik dan actionable",
    "Rekomendasi kedua",
    "Rekomendasi ketiga"
  ]
}

Aturan:
- confidence adalah integer 0-100
- severity: "Rendah" (gejala ringan, area kecil), "Sedang" (gejala menengah), "Tinggi" (parah, luas)
- Jika daun sehat: disease_name="Daun Sehat", severity="Rendah", confidence>90
- Berikan 3-5 rekomendasi penanganan yang praktis untuk petani cabai
- Selalu gunakan Bahasa Indonesia
PROMPT;
    }

    private function callOpenAI(string $apiKey, string $base64Image, string $prompt): array
    {
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $apiKey,
            'Content-Type' => 'application/json',
        ])->timeout(30)->post('https://api.openai.com/v1/chat/completions', [
            'model' => config('ai.openai_model', 'gpt-4o'),
            'max_tokens' => 600,
            'messages' => [
                ['role' => 'system', 'content' => $prompt],
                [
                    'role' => 'user',
                    'content' => [
                        ['type' => 'text', 'text' => 'Analisis foto daun cabai ini. Identifikasi penyakit, tingkat keparahan, dan berikan rekomendasi penanganan.'],
                        [
                            'type' => 'image_url',
                            'image_url' => [
                                'url' => 'data:image/jpeg;base64,' . $base64Image,
                            ],
                        ],
                    ],
                ],
            ],
        ]);

        $response->throw();
        $content = $response->json('choices.0.message.content', '');
        return $this->parseAiResponse($content);
    }

    private function callGemini(string $apiKey, string $base64Image, string $prompt): array
    {
        $model = config('ai.gemini_model', 'gemini-1.5-flash');
        $url = "https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$apiKey}";

        $response = Http::timeout(30)->post($url, [
            'contents' => [
                [
                    'role' => 'user',
                    'parts' => [
                        ['text' => $prompt . "\n\nAnalisis foto daun cabai ini. Identifikasi penyakit, tingkat keparahan, dan berikan rekomendasi penanganan."],
                        [
                            'inline_data' => [
                                'mime_type' => 'image/jpeg',
                                'data' => $base64Image,
                            ],
                        ],
                    ],
                ],
            ],
            'generationConfig' => [
                'temperature' => 0.3,
                'maxOutputTokens' => 600,
            ],
        ]);

        $response->throw();
        $content = $response->json('candidates.0.content.parts.0.text', '');
        return $this->parseAiResponse($content);
    }

    private function parseAiResponse(string $raw): array
    {
        $cleaned = trim($raw);

        if (str_starts_with($cleaned, '```')) {
            $cleaned = preg_replace('/^```(json)?\s*\n?/', '', $cleaned);
            $cleaned = preg_replace('/\n?```\s*$/', '', $cleaned);
        }

        $json = json_decode($cleaned, true);

        if (!is_array($json)) {
            throw new \RuntimeException('Respons AI tidak valid: ' . $cleaned);
        }

        return [
            'disease_name' => $json['disease_name'] ?? 'Tidak Diketahui',
            'scientific_name' => $json['scientific_name'] ?? '-',
            'severity' => $json['severity'] ?? 'Sedang',
            'confidence' => (int) ($json['confidence'] ?? 0),
            'recommendations' => $json['recommendations'] ?? [],
        ];
    }
}
