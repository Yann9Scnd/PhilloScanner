import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/disease_model.dart';
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
      version: 3,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS diseases');
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
    // 1. Diseases dataset table
    await db.execute('''
      CREATE TABLE diseases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        scientific_name TEXT NOT NULL,
        category TEXT NOT NULL,
        image_url TEXT NOT NULL,
        description TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        prevention_steps TEXT NOT NULL
      )
    ''');

    // 2. Scan Results table (ESP32 photos & AI diagnosis)
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

    // 3. Sensor Readings table (telemetri ESP32 Node 2)
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
        pump_status TEXT NOT NULL DEFAULT 'Standby',
        timestamp TEXT NOT NULL DEFAULT ''
      )
    ''');

    // Seed initial disease dataset
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed Dataset Diseases
    final initialDiseases = [
      const DiseaseModel(
        name: 'Bercak Daun (Leaf Spot)',
        scientificName: 'Cercospora capsici',
        category: 'Jamur',
        imageUrl:
            'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Bercak%20Daun',
        description:
            'Penyakit bercak daun disebabkan jamur Cercospora capsici yang menyerang daun cabai. Muncul bercak cokelat keabu-abuan yang menyebar dari daun bagian bawah ke atas.',
        symptoms: 'Bercak lingkaran kecil cokelat tua dengan pusat kelabu, daun menguning lalu rontok.',
        preventionSteps: [
          'Pilih benih varietas tahan penyakit.',
          'Atur jarak tanam agar sirkulasi udara lancar.',
          'Hindari penyiraman dari atas daun dan jaga kebersihan lahan.'
        ],
      ),
      const DiseaseModel(
        name: 'Karat Daun (Rust)',
        scientificName: 'Puccinia sorghi',
        category: 'Jamur',
        imageUrl:
            'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Karat%20Daun',
        description:
            'Penyakit karat menyerang daun dengan bintik oranye keemasan seperti karat pada permukaan bawah daun, umum muncul pada musim lembap.',
        symptoms: 'Pustul berisi spora berwarna serbuk karat cokelat kemerahan di permukaan bawah daun.',
        preventionSteps: [
          'Gunakan varietas tahan karat.',
          'Lakukan rotasi tanaman secara teratur.',
          'Jaga sirkulasi udara dan hindari kelembapan berlebih.'
        ],
      ),
      const DiseaseModel(
        name: 'Layu Fusarium',
        scientificName: 'Fusarium oxysporum',
        category: 'Jamur',
        imageUrl:
            'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Layu%20Fusarium',
        description:
            'Penyakit layu yang disebabkan jamur tanah Fusarium oxysporum. Tanaman layu mendadak dan pembuluh batang berwarna cokelat.',
        symptoms: 'Daun bawah menguning lalu layu, batang tampak cekung, dan pangkal batang membusuk.',
        preventionSteps: [
          'Gunakan benih sehat dan varietas tahan layu.',
          'Sterilkan media tanam dengan cara solarisasi.',
          'Cabut dan musnahkan tanaman yang terinfeksi.'
        ],
      ),
      const DiseaseModel(
        name: 'Antraknosa (Patek)',
        scientificName: 'Colletotrichum capsici',
        category: 'Jamur',
        imageUrl:
            'https://placehold.co/600x400/7CBF8A/FFFFFF?text=Antraknosa',
        description:
            'Penyakit patek menyerang buah dan daun cabai. Bercak cokelat dengan pusat lebih gelap seperti cincin dan buah membusuk berlendir.',
        symptoms: 'Bercak cekung cokelat pada buah dengan cincin spora oranye kemerahan, daun menguning.',
        preventionSteps: [
          'Gunakan fungisida nabati seperti ekstrak bawang putih.',
          'Panen tepat waktu dan buang buah yang terserang.',
          'Jaga kebersihan alat dan gulma sekitar lahan.'
        ],
      ),
      const DiseaseModel(
        name: 'Busuk Akar (Root Rot)',
        scientificName: 'Pythium spp.',
        category: 'Bakteri',
        imageUrl:
            'https://placehold.co/600x400/6B8FBF/FFFFFF?text=Busuk%20Akar',
        description:
            'Busuk akar berkembang akibat media tanam terlalu basah dan serangan patogen tanah. Akar membusuk sehingga tanaman tidak dapat menyerap air.',
        symptoms: 'Daun menguning tiba-tiba, layu, dan batang bagian bawah lembek berair.',
        preventionSteps: [
          'Atur drainase pot atau media tanam.',
          'Hentikan penyiraman sementara hingga media agak kering.',
          'Gunakan agen hayati Trichoderma pada media tanam.'
        ],
      ),
      const DiseaseModel(
        name: 'Layu Bakteri',
        scientificName: 'Ralstonia solanacearum',
        category: 'Bakteri',
        imageUrl:
            'https://placehold.co/600x400/6B8FBF/FFFFFF?text=Layu%20Bakteri',
        description:
            'Penyakit layu bakteri yang mematikan pada cabai. Bakteri menyumbat pembuluh sehingga tanaman layu permanen meski tanah lembap.',
        symptoms: 'Layu cepat tanpa daun menguning, batang dipotong mengeluarkan lendir putih, akar membusuk.',
        preventionSteps: [
          'Gunakan varietas tahan dan benih bebas penyakit.',
          'Lakukan rotasi dengan tanaman bukan golongan terong-terongan.',
          'Solarisasi tanah sebelum penanaman.'
        ],
      ),
      const DiseaseModel(
        name: 'Bercak Bakteri',
        scientificName: 'Xanthomonas campestris',
        category: 'Bakteri',
        imageUrl:
            'https://placehold.co/600x400/6B8FBF/FFFFFF?text=Bercak%20Bakteri',
        description:
            'Bercak bakteri menyerang daun dan buah. Bercak cokelat basah dengan tepi kuning yang dapat menyebabkan daun gugur.',
        symptoms: 'Bercak kecil berair cokelat yang menyatu, daun keriting dan rontok.',
        preventionSteps: [
          'Gunakan benih bebas penyakit.',
          'Hindari penyiraman dengan percikan air.',
          'Pisahkan dan buang tanaman yang sakit.'
        ],
      ),
      const DiseaseModel(
        name: 'Virus Mosaik',
        scientificName: 'Cucumber mosaic virus (CMV)',
        category: 'Virus',
        imageUrl:
            'https://placehold.co/600x400/C9A86B/FFFFFF?text=Virus%20Mosaik',
        description:
            'Virus mosaik disebarkan oleh kutu daun. Daun tampak belang-belang kuning-hijau, tanaman kerdil, dan buah kecil tidak normal.',
        symptoms: 'Daun belang mosaik, keriting, tepi menggulung, dan tanaman kerdil.',
        preventionSteps: [
          'Kendalikan kutu daun sebagai vektor penyebar virus.',
          'Gunakan benih bebas virus.',
          'Cabut tanaman terinfeksi segera.'
        ],
      ),
      const DiseaseModel(
        name: 'Daun Keriting Kuning (Virus Kuning)',
        scientificName: 'Begomovirus (PepYLCV)',
        category: 'Virus',
        imageUrl:
            'https://placehold.co/600x400/C9A86B/FFFFFF?text=Virus%20Kuning',
        description:
            'Penyakit kuning keriting disebarkan kutu kebul. Daun muda menguning dan mengeriting sehingga pertumbuhan terhambat.',
        symptoms: 'Daun muda menguning dan mengeriting, tanaman kerdil, dan bunga rontok.',
        preventionSteps: [
          'Pasang perangkap kuning untuk menangkap kutu kebul.',
          'Tutup lahan dengan mulsa plastik perak.',
          'Gunakan varietas tahan virus kuning.'
        ],
      ),
      const DiseaseModel(
        name: 'Kutu Daun (Aphid)',
        scientificName: 'Myzus persicae',
        category: 'Hama',
        imageUrl:
            'https://placehold.co/600x400/C97B6B/FFFFFF?text=Kutu%20Daun',
        description:
            'Serangan hama kutu daun mengisap cairan tanaman dan menjadi vektor virus. Koloni kutu tampak di pucuk dan daun muda.',
        symptoms: 'Daun keriting dan lengket (embun madu), pucuk pertumbuhan terhambat.',
        preventionSteps: [
          'Kendalikan dengan predator alami seperti kepik.',
          'Semprot air sabun atau pestisida nabati.',
          'Jaga kebersihan gulma di sekitar lahan.'
        ],
      ),
    ];

    for (var disease in initialDiseases) {
      await db.insert('diseases', disease.toMap());
    }

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

  Future<List<DiseaseModel>> getDiseases({String? category}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;
    if (category != null && category != 'Semua') {
      result = await db.query(
        'diseases',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'id ASC',
      );
    } else {
      result = await db.query('diseases', orderBy: 'id ASC');
    }
    return result.map((json) => DiseaseModel.fromMap(json)).toList();
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
}
