class ActuatorStateModel {
  final bool pumpAutoMode;
  final bool pumpActive;
  final bool mistingActive;
  final bool growLightActive;
  final bool fanActive;

  const ActuatorStateModel({
    required this.pumpAutoMode,
    required this.pumpActive,
    required this.mistingActive,
    required this.growLightActive,
    required this.fanActive,
  });

  factory ActuatorStateModel.initial() {
    return const ActuatorStateModel(
      pumpAutoMode: true,
      pumpActive: false,
      mistingActive: true,
      growLightActive: false,
      fanActive: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pump_auto_mode': pumpAutoMode ? 1 : 0,
      'pump_active': pumpActive ? 1 : 0,
      'misting_active': mistingActive ? 1 : 0,
      'grow_light_active': growLightActive ? 1 : 0,
      'fan_active': fanActive ? 1 : 0,
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
      mistingActive: parseBool(map['misting_active'], true),
      growLightActive: parseBool(map['grow_light_active'], false),
      fanActive: parseBool(map['fan_active'], true),
    );
  }

  ActuatorStateModel copyWith({
    bool? pumpAutoMode,
    bool? pumpActive,
    bool? mistingActive,
    bool? growLightActive,
    bool? fanActive,
  }) {
    return ActuatorStateModel(
      pumpAutoMode: pumpAutoMode ?? this.pumpAutoMode,
      pumpActive: pumpActive ?? this.pumpActive,
      mistingActive: mistingActive ?? this.mistingActive,
      growLightActive: growLightActive ?? this.growLightActive,
      fanActive: fanActive ?? this.fanActive,
    );
  }
}
