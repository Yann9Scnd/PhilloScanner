<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('actuator_states', function (Blueprint $table) {
            $table->boolean('pesticide_active')->default(false);
            $table->boolean('laser_active')->default(false);
            $table->boolean('led_active')->default(false);
        });
    }

    public function down(): void
    {
        Schema::table('actuator_states', function (Blueprint $table) {
            $table->dropColumn(['pesticide_active', 'laser_active', 'led_active']);
        });
    }
};
