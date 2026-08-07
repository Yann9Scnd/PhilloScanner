<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('scan_results', function (Blueprint $table) {
            $table->id();
            $table->string('device_id');
            $table->string('image_url');
            $table->string('disease_name');
            $table->string('scientific_name');
            $table->string('severity');
            $table->unsignedSmallInteger('confidence');
            $table->string('timestamp');
            $table->string('soil_moisture');
            $table->text('ai_recommendations');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('scan_results');
    }
};
