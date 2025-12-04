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
      version: 2,
      onCreate: _createDB,
      onOpen: (db) async {
      },
    );
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
        hasBeenRead BOOLEAN NOT NULL,
        notation INTEGER NOT NULL,
        isFavorite BOOLEAN NOT NULL,
        type TEXT NOT NULL
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
}
