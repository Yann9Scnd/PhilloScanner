<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sensor_readings', function (Blueprint $table) {
            if (!Schema::hasColumn('sensor_readings', 'battery_level')) {
                $table->string('battery_level')->nullable();
            }
            if (!Schema::hasColumn('sensor_readings', 'leaf_distance')) {
                $table->string('leaf_distance')->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::table('sensor_readings', function (Blueprint $table) {
            if (Schema::hasColumn('sensor_readings', 'battery_level')) {
                $table->dropColumn('battery_level');
            }
            if (Schema::hasColumn('sensor_readings', 'leaf_distance')) {
                $table->dropColumn('leaf_distance');
            }
        });
    }
};
