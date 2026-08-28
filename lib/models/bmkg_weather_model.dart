class BmkgLocationModel {
  final String adm4;
  final String provinsi;
  final String kotkab;
  final String kecamatan;
  final String desa;

  const BmkgLocationModel({
    required this.adm4,
    required this.provinsi,
    required this.kotkab,
    required this.kecamatan,
    required this.desa,
  });

  factory BmkgLocationModel.fromJson(Map<String, dynamic> json) {
    return BmkgLocationModel(
      adm4: (json['adm4'] as String?) ?? '',
      provinsi: (json['provinsi'] as String?) ?? 'Jawa Timur',
      kotkab: (json['kotkab'] as String?) ?? 'Kota Malang',
      kecamatan: (json['kecamatan'] as String?) ?? 'Lowokwaru',
      desa: (json['desa'] as String?) ?? 'Jatimulyo',
    );
  }

  Map<String, dynamic> toJson() => {
        'adm4': adm4,
        'provinsi': provinsi,
        'kotkab': kotkab,
        'kecamatan': kecamatan,
        'desa': desa,
      };
}

class BmkgWeatherItem {
  final String datetime;
  final String localDatetime;
  final double temp;
  final int humidity;
  final String weatherDesc;
  final String weatherDescEn;
  final double windSpeed;
  final String windDirection;
  final int weatherCode;
  final String? imageUrl;

  const BmkgWeatherItem({
    required this.datetime,
    required this.localDatetime,
    required this.temp,
    required this.humidity,
    required this.weatherDesc,
    required this.weatherDescEn,
    required this.windSpeed,
    required this.windDirection,
    required this.weatherCode,
    this.imageUrl,
  });

  factory BmkgWeatherItem.fromJson(Map<String, dynamic> json) {
    num tempNum = json['t'] as num? ?? 25;
    num wsNum = json['ws'] as num? ?? 0;
    num huNum = json['hu'] as num? ?? 70;
    num weatherNum = json['weather'] as num? ?? 1;

    return BmkgWeatherItem(
      datetime: (json['datetime'] as String?) ?? '',
      localDatetime: (json['local_datetime'] as String?) ?? '',
      temp: tempNum.toDouble(),
      humidity: huNum.toInt(),
      weatherDesc: (json['weather_desc'] as String?) ?? 'Cerah',
      weatherDescEn: (json['weather_desc_en'] as String?) ?? 'Sunny',
      windSpeed: wsNum.toDouble(),
      windDirection: (json['wd'] as String?) ?? 'N',
      weatherCode: weatherNum.toInt(),
      imageUrl: json['image'] as String?,
    );
  }
}

class BmkgWeatherModel {
  final BmkgLocationModel location;
  final BmkgWeatherItem currentWeather;
  final List<BmkgWeatherItem> forecastList;
  final bool isMock;

  const BmkgWeatherModel({
    required this.location,
    required this.currentWeather,
    required this.forecastList,
    this.isMock = false,
  });

  factory BmkgWeatherModel.fromJson(Map<String, dynamic> json) {
    final lokasiJson = (json['lokasi'] as Map<String, dynamic>?) ?? {};
    final location = BmkgLocationModel.fromJson(lokasiJson);

    final dataList = (json['data'] as List?) ?? [];
    final List<BmkgWeatherItem> items = [];

    if (dataList.isNotEmpty && dataList.first is Map) {
      final firstData = dataList.first as Map<String, dynamic>;
      final cuacaArray = firstData['cuaca'] as List?;
      if (cuacaArray != null) {
        for (final group in cuacaArray) {
          if (group is List) {
            for (final item in group) {
              if (item is Map) {
                items.add(BmkgWeatherItem.fromJson(item.cast<String, dynamic>()));
              }
            }
          }
        }
      }
    }

    final currentWeather = items.isNotEmpty
        ? items.first
        : const BmkgWeatherItem(
            datetime: '',
            localDatetime: '',
            temp: 26.0,
            humidity: 75,
            weatherDesc: 'Cerah Berawan',
            weatherDescEn: 'Partly Cloudy',
            windSpeed: 4.5,
            windDirection: 'NE',
            weatherCode: 2,
          );

    return BmkgWeatherModel(
      location: location,
      currentWeather: currentWeather,
      forecastList: items,
    );
  }

  /// Data cuaca cadangan jika offline/koneksi bermasalah
  factory BmkgWeatherModel.mock({String adm4 = '35.73.05.1007', String desa = 'Jatimulyo'}) {
    final mockLocation = BmkgLocationModel(
      adm4: adm4,
      provinsi: 'Jawa Timur',
      kotkab: 'Kota Malang',
      kecamatan: 'Lowokwaru',
      desa: desa,
    );

    const mockItem = BmkgWeatherItem(
      datetime: '2026-08-08T00:00:00Z',
      localDatetime: '2026-08-08 07:00:00',
      temp: 27.0,
      humidity: 68,
      weatherDesc: 'Cerah Berawan',
      weatherDescEn: 'Partly Cloudy',
      windSpeed: 4.2,
      windDirection: 'NE',
      weatherCode: 2,
    );

    return BmkgWeatherModel(
      location: mockLocation,
      currentWeather: mockItem,
      forecastList: const [mockItem],
      isMock: true,
    );
  }
}
