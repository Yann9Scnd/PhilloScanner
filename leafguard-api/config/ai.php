<?php

return [
    'provider' => env('AI_PROVIDER', 'openrouter'),

    'openrouter_key' => env('AI_OPENROUTER_KEY', ''),
    'openrouter_model' => env('AI_OPENROUTER_MODEL', 'nvidia/nemotron-3-nano-omni-30b-a3b-reasoning:free'),

    'gemini_key' => env('AI_GEMINI_KEY', ''),
    'gemini_model' => env('AI_GEMINI_MODEL', 'gemini-1.5-flash'),

    'openai_key' => env('AI_OPENAI_KEY', ''),
    'openai_model' => env('AI_OPENAI_MODEL', 'gpt-4o'),
];
