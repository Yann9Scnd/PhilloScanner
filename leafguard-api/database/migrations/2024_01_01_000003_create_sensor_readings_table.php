<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sensor_readings', function (Blueprint $table) {
            $table->id();
            $table->string('device_id')->nullable();
            $table->string('soil_moisture')->nullable();
            $table->string('temperature')->nullable();
            $table->string('air_humidity')->nullable();
            $table->string('light_intensity')->nullable();
            $table->string('water_tank_level')->nullable();
            $table->string('soil_ph')->nullable();
            $table->string('pump_status')->nullable();
            $table->string('timestamp')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sensor_readings');
    }
};
