import 'equipment.dart';

class Room {
  final int? id;
  final String name;
  final List<Equipment> equipments;
  final DateTime createdAt;

  Room({
    this.id,
    required this.name,
    this.equipments = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Room copyWith({
    int? id,
    String? name,
    List<Equipment>? equipments,
    DateTime? createdAt,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      equipments: equipments ?? this.equipments,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get equipmentCount => equipments.length;
}