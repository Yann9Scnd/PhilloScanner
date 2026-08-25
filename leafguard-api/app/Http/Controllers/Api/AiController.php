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

        $provider = config('ai.provider', 'openrouter');
        $apiKey = match ($provider) {
            'openai' => config('ai.openai_key', ''),
            'gemini' => config('ai.gemini_key', ''),
            default => config('ai.openrouter_key', ''),
        };

        if (empty($apiKey)) {
            return response()->json([
                'error' => "API Key untuk provider '$provider' belum dikonfigurasi di server.",
            ], 500);
        }

        $prompt = $this->getPrompt();

        try {
            $result = match ($provider) {
                'openai' => $this->callOpenAI($apiKey, $request->image, $prompt),
                'gemini' => $this->callGemini($apiKey, $request->image, $prompt),
                default => $this->callOpenRouter($apiKey, $request->image, $prompt),
            };
            return response()->json($result);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Gagal menganalisis: ' . $e->getMessage(),
            ], 500);
        }
    }

    public function chat(Request $request)
    {
        $request->validate([
            'message' => 'required|string|max:2000',
        ]);

        $provider = config('ai.provider', 'openrouter');
        $apiKey = match ($provider) {
            'openai' => config('ai.openai_key', ''),
            'gemini' => config('ai.gemini_key', ''),
            default => config('ai.openrouter_key', ''),
        };

        if (empty($apiKey)) {
            return response()->json([
                'reply' => 'API Key belum dikonfigurasi. Silakan hubungi admin.',
            ]);
        }

        $systemPrompt = "Kamu adalah asisten AI ahli pertanian cabai (Capsicum annuum) bernama ChiliGuard AI.
Kamu membantu petani cabai dengan pertanyaan tentang:
- Penyakit daun cabai (Cercospora, Antraknosa, Keriting Daun, Bule/Layu Virus, dll)
- Hama dan pengendaliannya
- Pemupukan dan nutrisi yang tepat
- Irigasi dan pengaturan air
- Tips budidaya cabai yang baik

Aturan:
- Selalu jawab dalam Bahasa Indonesia yang mudah dipahami petani
- Berikan jawaban yang praktis dan actionable
- Jangan berlebihan, jawab singkat dan to the point (maks 3-4 kalimat)
- Jika tidak yakin, katakan dengan jujur";

        try {
            $reply = $this->callChatApi($apiKey, $request->message, $systemPrompt);
            return response()->json(['reply' => $reply]);
        } catch (\Exception $e) {
            return response()->json([
                'reply' => 'Maaf, terjadi gangguan pada AI. Silakan coba lagi.',
            ]);
        }
    }

    private function callChatApi(string $apiKey, string $userMessage, string $systemPrompt): string
    {
        $model = config('ai.openrouter_model', 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free');

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $apiKey,
            'Content-Type' => 'application/json',
            'HTTP-Referer' => 'https://philloscanner.app',
            'X-Title' => 'PhilloScanner',
        ])->timeout(30)->post('https://openrouter.ai/api/v1/chat/completions', [
            'model' => $model,
            'max_tokens' => 300,
            'messages' => [
                ['role' => 'system', 'content' => $systemPrompt],
                ['role' => 'user', 'content' => $userMessage],
            ],
        ]);

        $response->throw();
        $body = $response->json();
        $message = $body['choices'][0]['message'] ?? [];
        return $message['content'] ?? $message['reasoning'] ?? 'Maaf, saya tidak bisa merespons saat ini.';
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

    private function callOpenRouter(string $apiKey, string $base64Image, string $prompt): array
    {
        $model = config('ai.openrouter_model', 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free');

        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . $apiKey,
            'Content-Type' => 'application/json',
            'HTTP-Referer' => 'https://philloscanner.app',
            'X-Title' => 'PhilloScanner',
        ])->timeout(30)->post('https://openrouter.ai/api/v1/chat/completions', [
            'model' => $model,
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
        $body = $response->json();
        $message = $body['choices'][0]['message'] ?? [];
        $content = $message['content'] ?? $message['reasoning'] ?? '';
        if (empty($content)) {
            $content = json_encode($body);
        }
        return $this->parseAiResponse($content);
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

        // Hapus thinking tags jika ada
        $cleaned = preg_replace('/<think>.*?<\/think>/us', '', $cleaned);
        $cleaned = preg_replace('/<reasoning>.*?<\/reasoning>/us', '', $cleaned);
        $cleaned = preg_replace('/<thinking>.*?<\/thinking>/us', '', $cleaned);
        $cleaned = trim($cleaned);

        // Coba extract JSON dari teks (handle nested braces)
        $braceStart = strpos($cleaned, '{');
        $braceEnd = strrpos($cleaned, '}');
        if ($braceStart !== false && $braceEnd !== false && $braceEnd > $braceStart) {
            $cleaned = substr($cleaned, $braceStart, $braceEnd - $braceStart + 1);
        }

        if (str_starts_with($cleaned, '```')) {
            $cleaned = preg_replace('/^```(json)?\s*\n?/', '', $cleaned);
            $cleaned = preg_replace('/\n?```\s*$/', '', $cleaned);
        }

        $json = json_decode(trim($cleaned), true);

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
