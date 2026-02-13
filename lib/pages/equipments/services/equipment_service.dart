import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/room.dart';
import '../models/equipment.dart';
import '../models/appliance.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EquipmentService {
  static final EquipmentService _instance = EquipmentService._internal();
  factory EquipmentService() => _instance;
  EquipmentService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'home_inventory.db');

    return await openDatabase(
      path,
      version: 1, // Version simplifiée à 1
      onCreate: (db, version) async {
        // Table des pièces
        await db.execute('''
          CREATE TABLE rooms(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        // Table des équipements (version actuelle)
        await db.execute('''
          CREATE TABLE equipments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            room_name TEXT NOT NULL,
            consumption_per_hour REAL NOT NULL,
            usage_hours_per_day REAL NOT NULL,
            usage_days_per_week INTEGER NOT NULL,
            icon_code_point INTEGER,
            icon_font_family TEXT,
            icon_font_package TEXT,
            has_custom_values INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL
          )
        ''');

        // Insérer les pièces par défaut
        final defaultRooms = [
          Room(name: 'Cuisine'),
          Room(name: 'Salle de bain'),
          Room(name: 'Chambre'),
          Room(name: 'Salon'),
        ];

        for (final room in defaultRooms) {
          await db.insert('rooms', room.toMap());
        }
      },
    );
  }

  // CRUD pour les pièces
  Future<int> insertRoom(Room room) async {
    final db = await database;
    return await db.insert('rooms', room.toMap());
  }

  Future<List<Room>> getAllRooms() async {
    final db = await database;
    final maps = await db.query('rooms', orderBy: 'created_at DESC');
    return maps.map((map) => Room.fromMap(map)).toList();
  }

  Future<int> updateRoom(Room room) async {
    final db = await database;
    return await db.update(
      'rooms',
      room.toMap(),
      where: 'id = ?',
      whereArgs: [room.id],
    );
  }

  Future<int> deleteRoom(int id) async {
    final db = await database;
    // Supprimer aussi les équipements de cette pièce
    await db.delete(
      'equipments',
      where: 'room_name IN (SELECT name FROM rooms WHERE id = ?)',
      whereArgs: [id],
    );
    return await db.delete(
      'rooms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD pour les équipements
  Future<int> insertEquipment(Equipment equipment) async {
    final db = await database;
    return await db.insert('equipments', equipment.toMap());
  }

  Future<int> updateEquipment(Equipment equipment) async {
    final db = await database;
    return await db.update(
      'equipments',
      equipment.toMap(),
      where: 'id = ?',
      whereArgs: [equipment.id],
    );
  }

  Future<int> deleteEquipment(int id) async {
    final db = await database;
    return await db.delete(
      'equipments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Equipment>> getEquipmentsByRoom(String roomName) async {
    final db = await database;
    final maps = await db.query(
      'equipments',
      where: 'room_name = ?',
      whereArgs: [roomName],
      orderBy: 'created_at DESC',
    );
    return await Equipment.fromMapList(maps);
  }

  Future<List<Equipment>> getAllEquipments() async {
    final db = await database;
    final maps = await db.query('equipments', orderBy: 'created_at DESC');
    return await Equipment.fromMapList(maps);
  }

  Future<Map<String, List<Equipment>>> getEquipmentsByRooms() async {
    final rooms = await getAllRooms();
    final result = <String, List<Equipment>>{};
    
    for (final room in rooms) {
      final equipments = await getEquipmentsByRoom(room.name);
      result[room.name] = equipments;
    }
    
    return result;
  }

  // Méthode pour mettre à jour le nom de la pièce dans tous les équipements
  Future<int> updateRoomNameInEquipments(String oldRoomName, String newRoomName) async {
    final db = await database;
    return await db.update(
      'equipments',
      {'room_name': newRoomName},
      where: 'room_name = ?',
      whereArgs: [oldRoomName],
    );
  }

  // Statistiques
  Future<InventoryStats> getInventoryStats() async {
    final allEquipments = await getAllEquipments();
    final kwhPrice = await Equipment.getKwhPrice(); // Récupère le prix une fois

    final totalMonthlyConsumption = allEquipments.fold(0.0, (sum, equipment) {
      return sum + equipment.monthlyConsumptionKwh;
    });
    
    final totalMonthlyCost = allEquipments.fold(0.0, (sum, equipment) {
      return sum + equipment.monthlyCostWithPrice(kwhPrice);
    });
    
    return InventoryStats(
      monthlyConsumption: totalMonthlyConsumption,
      monthlyCost: totalMonthlyCost,
      equipmentCount: allEquipments.length,
      totalConsumption: totalMonthlyConsumption * 12,
    );
  }
}

class InventoryStats {
  final double monthlyConsumption; // kWh/mois
  final double monthlyCost; // €/mois
  final int equipmentCount;
  final double totalConsumption; // kWh/an

  InventoryStats({
    required this.monthlyConsumption,
    required this.monthlyCost,
    required this.equipmentCount,
    required this.totalConsumption,
  });
}