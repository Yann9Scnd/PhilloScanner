<?php

return [
    'provider' => env('AI_PROVIDER', 'gemini'),
    'gemini_key' => env('AI_GEMINI_KEY', ''),
    'gemini_model' => env('AI_GEMINI_MODEL', 'gemini-1.5-flash'),
    'openai_key' => env('AI_OPENAI_KEY', ''),
    'openai_model' => env('AI_OPENAI_MODEL', 'gpt-4o'),
];
