import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:phylloscanner/database/database_helper.dart';
import 'package:phylloscanner/models/scan_result_model.dart';
import 'package:phylloscanner/models/sensor_data_model.dart';

void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = await getDatabasesPath();
    final dbFile = File('$dir/phylloscanner.db');
    if (dbFile.existsSync()) {
      dbFile.deleteSync();
    }
  });

  test('SQLite dibuat, dan query berjalan (tanpa error)', () async {
    final db = await DatabaseHelper.instance.database;

    final scans = await db.query('scan_results');
    expect(scans, isEmpty, reason: 'Tidak ada seed dummy, DB harus kosong');

    final scanColumns =
        (await db.rawQuery('PRAGMA table_info(scan_results)'))
            .map((c) => c['name'] as String)
            .toSet();
    expect(scanColumns, containsAll(['sector', 'temperature_at_scan']));

    final sensorColumns =
        (await db.rawQuery('PRAGMA table_info(sensor_readings)'))
            .map((c) => c['name'] as String)
            .toSet();
    expect(sensorColumns,
        containsAll(['air_humidity', 'light_intensity', 'water_tank_level', 'soil_ph']));
  });

  test('getAllScans + insertScan round-trip', () async {
    final helper = DatabaseHelper.instance;
    final before = await helper.getAllScans();
    expect(before, isEmpty, reason: 'DB kosong (dummy dihapus)');

    await helper.insertScan(ScanResultModel(
      deviceId: 'ESP32-CAM Test',
      imageUrl: 'https://example.com/leaf.jpg',
      diseaseName: 'Test Penyakit',
      scientificName: 'Testus spp.',
      severity: 'Sedang',
      confidence: 90,
      timestamp: '11 Agu 2026 • 10:00',
      soilMoisture: '60%',
      sector: 'Bedeng Uji',
      temperatureAtScan: 29.5,
      aiRecommendations: const ['Rekomendasi A', 'Rekomendasi B'],
    ));

    final after = await helper.getAllScans();
    expect(after.length, 1);
    expect(after.first.sector, 'Bedeng Uji');
    expect(after.first.temperatureAtScan, 29.5);
    expect(after.first.aiRecommendations.length, 2);
  });

  test('insertSensorReading + getLatestSensorReading round-trip', () async {
    final helper = DatabaseHelper.instance;
    await helper.insertSensorReading(SensorDataModel.initial().copyWith(
      soilMoisture: 55.0,
      airHumidity: 70.5,
    ));

    final latest = await helper.getLatestSensorReading();
    expect(latest, isNotNull);
    expect(latest!.soilMoisture, 55.0);
    expect(latest.airHumidity, 70.5);
  });
}
