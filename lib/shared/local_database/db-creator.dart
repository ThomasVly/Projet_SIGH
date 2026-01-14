import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper pour gérer la base de données SQLite
class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  /// Récupère l'instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('TEMPDBNAME.db');
    return _database!;
  }

  /// Récupère le chemin complet de la base de données
  Future<String> getDatabasePath() async {
    final dbPath = await getDatabasesPath();
    return join(dbPath, 'TEMPDBNAME.db');
  }

  /// Initialise la base de données
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4, // Incrémentation de la version pour forcer la mise à jour
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
      },
    );
  }

  /// Migration de la base de données
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Ajouter les nouvelles colonnes à la table Content si elles n'existent pas
      try {
        await db.execute('ALTER TABLE Content ADD COLUMN category TEXT NOT NULL DEFAULT "Électricité"');
      } catch (e) {
        print('Colonne category déjà existante ou erreur: $e');
      }

      try {
        await db.execute('ALTER TABLE Content ADD COLUMN readingTime INTEGER NOT NULL DEFAULT 5');
      } catch (e) {
        print('Colonne readingTime déjà existante ou erreur: $e');
      }

      try {
        await db.execute('ALTER TABLE Content ADD COLUMN isFeatured BOOLEAN NOT NULL DEFAULT 0');
      } catch (e) {
        print('Colonne isFeatured déjà existante ou erreur: $e');
      }

      try {
        await db.execute('ALTER TABLE Content ADD COLUMN pdfUrl TEXT NOT NULL DEFAULT ""');
      } catch (e) {
        print('Colonne pdfUrl déjà existante ou erreur: $e');
      }
    }
  }

  /// Crée la table Users
  String initUserTable()  {
    var createUserTable  = ('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        localisation TEXT NOT NULL,
        fullHours DATETIME,
        offHours DATETIME,
        nbPoints INTEGER NOT NULL
      )
    ''');
    return createUserTable;
  }

  /// Crée la table Content (Articles, Tutorials, Flashcards)
  String initContentTable()  {
    var createContentTable  = ('''
      CREATE TABLE Content (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        tags TEXT NOT NULL,
        hasBeenRead BOOLEAN NOT NULL DEFAULT 0,
        notation INTEGER NOT NULL,
        isFavorite BOOLEAN NOT NULL DEFAULT 0,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        readingTime INTEGER NOT NULL,
        isFeatured BOOLEAN NOT NULL DEFAULT 0,
        pdfUrl TEXT NOT NULL
      )
    ''');
    return createContentTable;
  }

  /// Crée la table Quizzes
  String initQuizzesTable()  {
    var createQuizzesTable  = ('''
      CREATE TABLE Quizzes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        completed BOOLEAN NOT NULL,
        score INTEGER NOT NULL,
        completionTime INTEGER NOT NULL,
        reward INTEGER NOT NULL
      )
    ''');
    return createQuizzesTable;
  }

  /// Crée la table Challenges
  String initChallengesTable()  {
    var createChallengesTable  = ('''
      CREATE TABLE Challenges (
        id TEXT PRIMARY KEY,
        completed BOOLEAN NOT NULL,
        reward INTEGER NOT NULL
      )
    ''');
    return createChallengesTable;
  }

  /// Crée la table Bills
  String initBillsTable()  {
    var createBillsTable  = ('''
      CREATE TABLE Bills (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        content TEXT NOT NULL
      )
    ''');
    return createBillsTable;
  }

  /// Crée la table Alerts
  String initAlertsTable()  {
    var createAlertsTable  = ('''
      CREATE TABLE Alerts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        content TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');
    return createAlertsTable;
  }

  /// Crée la table Reminders
  String initRemindersTable()  {
    var createRemindersTable  = ('''
      CREATE TABLE Reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        correspondingEquipment INTEGER NOT NULL,
        content TEXT NOT NULL,
        FOREIGN KEY (correspondingEquipment) REFERENCES Equipments(id)
      )
    ''');
    return createRemindersTable;
  }

  /// Crée la table Equipments
  String initEquipmentsTable()  {
    var createEquipmentsTable  = ('''
      CREATE TABLE Equipments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        energyType TEXT NOT NULL,
        moyUseTime INTEGER NOT NULL,
        moyConso INTEGER NOT NULL,
        configuredConso INTEGER NOT NULL,
        configuredUseTime INTEGER NOT NULL,
        configured BOOLEAN NOT NULL
      )
    ''');
    return createEquipmentsTable;
  }

  /// Crée la table Badges
  String initBadgesTable()  {
    var createBadgesTable  = ('''
      CREATE TABLE Badges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        badgeTitle TEXT NOT NULL,
        badgeDescription TEXT NOT NULL,
        badgeIcon TEXT NOT NULL,
        badgeEarnedDate TEXT NOT NULL,
        badgeReward INTEGER NOT NULL
      )
    ''');
    return createBadgesTable;
  }

  String initHomeInventoryTable() {
    return '''
      CREATE TABLE home_inventory_equipments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        room_name TEXT NOT NULL,
        average_consumption REAL NOT NULL,
        average_cost REAL NOT NULL,
        usage_time REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''';
  }

  Future _createDB(Database db, int version) async {
    await db.execute(initUserTable());
    await db.execute(initContentTable());
    await db.execute(initQuizzesTable());
    await db.execute(initChallengesTable());
    await db.execute(initBillsTable());
    await db.execute(initAlertsTable());
    await db.execute(initRemindersTable());
    await db.execute(initBadgesTable());
    await db.execute(initEquipmentsTable());
    await db.execute(initHomeInventoryTable());

    // Indexs pour améliorer les performances de recherche
    await db.execute('CREATE INDEX idx_user ON Users(username)');
    await db.execute('CREATE INDEX idx_equipment ON Equipments(name)');
    await db.execute('CREATE INDEX idx_badge ON Badges(badgeTitle)');
    await db.execute('CREATE INDEX idx_challenge ON Challenges(id)');
    await db.execute('CREATE INDEX idx_quiz ON Quizzes(name)');
    await db.execute('CREATE INDEX idx_content ON Content(title,tags,type)');
  }

  /// Ferme la base de données
  Future close() async {
    final db = await instance.database;
    db.close();
  }

  /// Affiche le chemin de la base de données dans la console
  Future<void> printDatabasePath() async {
    final path = await getDatabasePath();
    print('===========================================');
    print('Chemin de la base de données SQLite :');
    print(path);
    print('===========================================');
  }

  /// Supprime complètement la base de données (utile pour les migrations importantes)
  Future<void> deleteDatabase() async {
    final path = await getDatabasePath();
    await databaseFactory.deleteDatabase(path);
    _database = null;
    print('Base de données supprimée avec succès');
  }

  /// Réinitialise complètement la base de données
  Future<void> resetDatabase() async {
    await deleteDatabase();
    _database = await _initDB('TEMPDBNAME.db');
    print('Base de données réinitialisée avec succès');
  }
}
