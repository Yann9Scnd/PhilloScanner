import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bmkg_weather_model.dart';

class BmkgRegionOption {
  final String adm4;
  final String name;
  final String region;

  const BmkgRegionOption({
    required this.adm4,
    required this.name,
    required this.region,
  });
}

class BmkgWeatherService {
  final http.Client _client;

  BmkgWeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Daftar pilihan wilayah BMKG — Malang & Kota Batu (daerah pengguna)
  static const List<BmkgRegionOption> presetRegions = [
    BmkgRegionOption(
      adm4: '35.73.05.1007',
      name: 'Jatimulyo, Lowokwaru',
      region: 'Kota Malang, Jatim',
    ),
    BmkgRegionOption(
      adm4: '35.73.04.1005',
      name: 'Sukun',
      region: 'Kota Malang, Jatim',
    ),
    BmkgRegionOption(
      adm4: '35.73.03.1010',
      name: 'Cemorokandang, Kedungkandang',
      region: 'Kota Malang, Jatim',
    ),
    BmkgRegionOption(
      adm4: '35.79.01.1003',
      name: 'Songgokerto, Batu',
      region: 'Kota Batu, Jatim',
    ),
    BmkgRegionOption(
      adm4: '35.79.02.2006',
      name: 'Bumiaji',
      region: 'Kota Batu, Jatim',
    ),
    BmkgRegionOption(
      adm4: '35.79.02.2003',
      name: 'Tulungrejo, Bumiaji',
      region: 'Kota Batu, Jatim',
    ),
    BmkgRegionOption(
      adm4: '35.79.03.2005',
      name: 'Mojorejo, Junrejo',
      region: 'Kota Batu, Jatim',
    ),
  ];

  /// Mengambil data cuaca terkini dari API BMKG
  Future<BmkgWeatherModel> fetchWeather({String adm4Code = '35.73.05.1007'}) async {
    final uri = Uri.parse('https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=$adm4Code');

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return BmkgWeatherModel.fromJson(decoded);
      } else {
        // Fallback jika API HTTP error
        return BmkgWeatherModel.mock(adm4: adm4Code);
      }
    } catch (_) {
      // Fallback jika koneksi gagal atau timeout
      return BmkgWeatherModel.mock(adm4: adm4Code);
    }
  }
}
