import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/activity_log_model.dart';
import '../models/scan_result_model.dart';
import '../models/sensor_data_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    _database = await _initDB('phylloscanner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS scan_results');
          await db.execute('DROP TABLE IF EXISTS sensor_readings');
          await _createDB(db, newVersion);
          return;
        }
        if (oldVersion < 3) {
          // Non-destructive upgrade: tambah kolom yang hilang agar cocok dgn model
          await _tryAlter(
            db,
            'scan_results',
            'sector TEXT NOT NULL DEFAULT \'Greenhouse Sektor A\'',
          );
          await _tryAlter(
            db,
            'scan_results',
            'temperature_at_scan TEXT NOT NULL DEFAULT \'28.0\'',
          );
          await _tryAlter(db, 'sensor_readings', 'air_humidity TEXT');
          await _tryAlter(db, 'sensor_readings', 'light_intensity TEXT');
          await _tryAlter(db, 'sensor_readings', 'water_tank_level TEXT');
          await _tryAlter(db, 'sensor_readings', 'soil_ph TEXT');
        }
        if (oldVersion < 4) {
          // Telemetri tambahan: kapasitas baterai & jarak daun (ultrasonik)
          await _tryAlter(
            db,
            'sensor_readings',
            'battery_level TEXT NOT NULL DEFAULT \'86\'',
          );
          await _tryAlter(
            db,
            'sensor_readings',
            'leaf_distance TEXT NOT NULL DEFAULT \'25\'',
          );
        }
        if (oldVersion < 5) {
          // Activity log riwayat (non-destructive: tabel baru)
          await db.execute('''
            CREATE TABLE IF NOT EXISTS activity_logs (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              subtitle TEXT NOT NULL,
              timestamp TEXT NOT NULL,
              type TEXT NOT NULL,
              sector TEXT NOT NULL,
              icon_name TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<void> _tryAlter(Database db, String table, String columnDef) async {
    try {
      await db.execute('ALTER TABLE $table ADD COLUMN $columnDef');
    } catch (_) {
      // Kolom sudah ada (mis. DB rusak dari versi lama) -> abaikan
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Scan Results table (ESP32 photos & AI diagnosis)
    await db.execute('''
      CREATE TABLE scan_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        image_url TEXT NOT NULL,
        disease_name TEXT NOT NULL,
        scientific_name TEXT NOT NULL,
        severity TEXT NOT NULL,
        confidence INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        soil_moisture TEXT NOT NULL,
        sector TEXT NOT NULL DEFAULT 'Greenhouse Sektor A',
        temperature_at_scan TEXT NOT NULL DEFAULT '28.0',
        ai_recommendations TEXT NOT NULL
      )
    ''');

    // 2. Sensor Readings table (telemetri ESP32 Node 2)
    await db.execute('''
      CREATE TABLE sensor_readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL DEFAULT 'Node 2: ESP32 Sensor',
        soil_moisture TEXT NOT NULL DEFAULT '0',
        temperature TEXT NOT NULL DEFAULT '0',
        air_humidity TEXT NOT NULL DEFAULT '0',
        light_intensity TEXT NOT NULL DEFAULT '0',
        water_tank_level TEXT NOT NULL DEFAULT '0',
        soil_ph TEXT NOT NULL DEFAULT '0',
        battery_level TEXT NOT NULL DEFAULT '86',
        leaf_distance TEXT NOT NULL DEFAULT '25',
        pump_status TEXT NOT NULL DEFAULT 'Standby',
        timestamp TEXT NOT NULL DEFAULT ''
      )
    ''');

    // 3. Activity Logs table (riwayat aktivitas)
    await db.execute('''
      CREATE TABLE activity_logs (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        type TEXT NOT NULL,
        sector TEXT NOT NULL,
        icon_name TEXT NOT NULL
      )
    ''');

    // Seed data awal (scan ESP32-CAM)
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed Initial ESP32 Scan Results
    final initialScans = [
      const ScanResultModel(
        deviceId: 'ESP32-CAM Sektor B-04',
        imageUrl:
            'https://lh3.googleusercontent.com/aida/AP1WRLsJNUTrlybw3NU7q_uVkGQ2i6ryWi7lAXAGkOSvK_H2Ptj28d2-iZ--leefUeHsmVULchMwRDed-DsFju613H_X7TztLlQM821oZKXYF_4PrWPd8DFjAvWQHWXhrFAGvB5Rrw8anPY1K0deDmtaCTLCD2H1WG9eT53kZBJqRDVh8-u1C4d2vm72Hr24gioVwOVzH9sz-OHjukpoyBkBBiPKQKF9t-eGPhcSyBcjKjHvrcTbgs5jR9GWKMok',
        diseaseName: 'Bercak Daun',
        scientificName: 'Cercospora capsici',
        severity: 'Sedang',
        confidence: 92,
        timestamp: '12 Okt 2023 • 14:30',
        soilMoisture: '58%',
        aiRecommendations: [
          'Kurangi kelembapan di sekitar area terdampak.',
          'Buang bagian daun yang rusak parah agar tidak menular.',
          'Berikan pupuk tambahan untuk memperkuat imun tanaman.'
        ],
      ),
      const ScanResultModel(
        deviceId: 'ESP32-CAM Sektor A-01',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDImDcqK7-2TTfEsSRFVDFrIL3dQC65jCejg5cgzzThGqbPc0YSXIKHK65Bv3w6jaLbb4vCHoWMCu1it6APEayNlB3gCHUyBhrdSpETKR_zOBRDhX55O8SMMDhqzDi2RxH30VpHV7n4_4owIfcONwCDp3rtJrW96aeAUp9p6I5ANQylU_4936R6VO1pIDMY2tjqDjPk1tXDSjMhqIVSkGUc9eeDfuMpN75K-HkO-Tgj3NvEUWr_LbPUVQ',
        diseaseName: 'Karat Daun',
        scientificName: 'Puccinia sorghi',
        severity: 'Rendah',
        confidence: 88,
        timestamp: '12 Okt 2023 • 11:15',
        soilMoisture: '62%',
        aiRecommendations: [
          'Semprotkan fungisida berbasis tembaga organik.',
          'Jaga sirkulasi udara antar tanaman.',
        ],
      ),
    ];

    for (var scan in initialScans) {
      await db.insert('scan_results', scan.toMap());
    }
  }

  Future<int> insertScan(ScanResultModel scan) async {
    final db = await instance.database;
    return await db.insert('scan_results', scan.toMap());
  }

  Future<List<ScanResultModel>> getAllScans() async {
    final db = await instance.database;
    final result = await db.query('scan_results', orderBy: 'id DESC');
    return result.map((json) => ScanResultModel.fromMap(json)).toList();
  }

  Future<ScanResultModel?> getLatestScan() async {
    final db = await instance.database;
    final result = await db.query('scan_results', orderBy: 'id DESC', limit: 1);
    if (result.isNotEmpty) {
      return ScanResultModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertSensorReading(SensorDataModel reading) async {
    final db = await instance.database;
    return await db.insert('sensor_readings', reading.toMap());
  }

  Future<SensorDataModel?> getLatestSensorReading() async {
    final db = await instance.database;
    final result = await db.query('sensor_readings', orderBy: 'id DESC', limit: 1);
    if (result.isEmpty) return null;
    return SensorDataModel.fromMap(result.first);
  }

  Future<int> insertActivity(ActivityLogModel activity) async {
    final db = await instance.database;
    return await db.insert('activity_logs', activity.toMap());
  }

  Future<List<ActivityLogModel>> getAllActivities() async {
    final db = await instance.database;
    final result = await db.query('activity_logs', orderBy: 'rowid DESC');
    return result.map((json) => ActivityLogModel.fromMap(json)).toList();
  }
}
