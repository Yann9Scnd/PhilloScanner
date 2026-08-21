class EspNodeModel {
  final String id;
  final String name;
  final String ip;
  final String type; // 'sensor' atau 'camera'

  const EspNodeModel({
    required this.id,
    required this.name,
    required this.ip,
    this.type = 'sensor',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ip': ip,
      'type': type,
    };
  }

  factory EspNodeModel.fromMap(Map<String, dynamic> map) {
    return EspNodeModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      ip: map['ip'] as String? ?? '',
      type: map['type'] as String? ?? 'sensor',
    );
  }

  EspNodeModel copyWith({
    String? id,
    String? name,
    String? ip,
    String? type,
  }) {
    return EspNodeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      type: type ?? this.type,
    );
  }
}
