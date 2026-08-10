<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('actuator_states', function (Blueprint $table) {
            $table->id();
            $table->boolean('pump_auto_mode')->default(true);
            $table->boolean('pump_active')->default(false);
            $table->boolean('misting_active')->default(true);
            $table->boolean('grow_light_active')->default(false);
            $table->boolean('fan_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('actuator_states');
    }
};
