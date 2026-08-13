class ActuatorStateModel {
  final bool pumpAutoMode;
  final bool pumpActive;
  final bool pesticideActive;

  const ActuatorStateModel({
    required this.pumpAutoMode,
    required this.pumpActive,
    required this.pesticideActive,
  });

  factory ActuatorStateModel.initial() {
    return const ActuatorStateModel(
      pumpAutoMode: true,
      pumpActive: false,
      pesticideActive: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pump_auto_mode': pumpAutoMode ? 1 : 0,
      'pump_active': pumpActive ? 1 : 0,
      'pesticide_active': pesticideActive ? 1 : 0,
    };
  }

  factory ActuatorStateModel.fromMap(Map<String, dynamic> map) {
    bool parseBool(dynamic val, bool fallback) {
      if (val == null) return fallback;
      if (val is bool) return val;
      if (val is num) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return fallback;
    }

    return ActuatorStateModel(
      pumpAutoMode: parseBool(map['pump_auto_mode'], true),
      pumpActive: parseBool(map['pump_active'], false),
      pesticideActive: parseBool(map['pesticide_active'], false),
    );
  }

  ActuatorStateModel copyWith({
    bool? pumpAutoMode,
    bool? pumpActive,
    bool? pesticideActive,
  }) {
    return ActuatorStateModel(
      pumpAutoMode: pumpAutoMode ?? this.pumpAutoMode,
      pumpActive: pumpActive ?? this.pumpActive,
      pesticideActive: pesticideActive ?? this.pesticideActive,
    );
  }
}
