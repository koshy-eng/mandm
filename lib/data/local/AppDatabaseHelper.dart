import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabaseHelper {
  static final AppDatabaseHelper _instance = AppDatabaseHelper._internal();
  factory AppDatabaseHelper() => _instance;
  AppDatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();

    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wheely.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      // onUpgrade: _onUpgrade,
    );
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE wishlist ADD COLUMN quantity INTEGER DEFAULT 1');
    }
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notify(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        action TEXT,
        topic TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ride(
        id INTEGER PRIMARY KEY,
        userId INTEGER,
        carId INTEGER,
        departureDate TEXT,
        departureTime TEXT,
        startLat TEXT,
        startLng TEXT,
        startName TEXT,
        destLat TEXT,
        destLng TEXT,
        destName TEXT,
        seats INTEGER,
        price INTEGER,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT,
        timestamp TEXT,
        isRead INTEGER
      )
    ''');

    await db.execute('''
  CREATE TABLE challenges (
    id INTEGER PRIMARY KEY,
    name TEXT,
    lat REAL,
    lng REAL,
    radius REAL,
    image TEXT,
    char_image TEXT,
    guide_image TEXT,
    video TEXT,
    "order" INTEGER,
    timer INTEGER,
    activity_id INTEGER,
    type TEXT,
    status TEXT,
    description TEXT,
    created_at TEXT,
    updated_at TEXT,

    -- Local progress management
    is_completed INTEGER DEFAULT 0,
    is_unlocked INTEGER DEFAULT 0,
    time_spent INTEGER DEFAULT 0,
    user_points INTEGER DEFAULT 0
  )
''');

    await db.execute('''
  CREATE TABLE quizzes (
    id INTEGER PRIMARY KEY,
    question TEXT,
    answers TEXT,
    correct_answer TEXT,
    points INTEGER,
    is_fake INTEGER,
    fake_text TEXT,
    fake_image TEXT,
    challenge_id INTEGER,
    created_at TEXT,
    updated_at TEXT,

    -- Local progress tracking
    is_completed INTEGER DEFAULT 0,
    is_unlocked INTEGER DEFAULT 0,
    user_selected INTEGER DEFAULT -1
  )
''');

  }
}
