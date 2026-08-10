<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Menyelaraskan scan_results dengan struktur model Flutter:
     * menambah kolom `sector` dan `temperature_at_scan`.
     */
    public function up(): void
    {
        Schema::table('scan_results', function (Blueprint $table) {
            if (!Schema::hasColumn('scan_results', 'sector')) {
                $table->string('sector')->default('Greenhouse Sektor A')->after('soil_moisture');
            }
            if (!Schema::hasColumn('scan_results', 'temperature_at_scan')) {
                $table->string('temperature_at_scan')->default('28.0')->after('sector');
            }
        });
    }

    public function down(): void
    {
        Schema::table('scan_results', function (Blueprint $table) {
            if (Schema::hasColumn('scan_results', 'sector')) {
                $table->dropColumn('sector');
            }
            if (Schema::hasColumn('scan_results', 'temperature_at_scan')) {
                $table->dropColumn('temperature_at_scan');
            }
        });
    }
};
