import '../database/database_helper.dart';
import '../models/disease_model.dart';
import '../models/scan_result_model.dart';

class ScanRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Get list of diseases in dataset, optionally filtered by category (Jamur, Bakteri, Virus)
  Future<List<DiseaseModel>> getDiseases({String? category}) async {
    return await _dbHelper.getDiseases(category: category);
  }

  /// Get all scan history captured by ESP32-CAM
  Future<List<ScanResultModel>> getScanHistory() async {
    return await _dbHelper.getAllScans();
  }

  /// Get the latest scan captured by ESP32-CAM
  Future<ScanResultModel?> getLatestScan() async {
    return await _dbHelper.getLatestScan();
  }

  /// Add a new photo analysis result from ESP32-CAM to database
  Future<int> addEspScanResult(ScanResultModel scan) async {
    return await _dbHelper.insertScan(scan);
  }
}
