import 'package:mandm/data/local/dbTablesHelpers/dbModels/db_models.dart';
import 'package:mandm/models/challenge_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ChallengeDbHelper {
  static final ChallengeDbHelper _instance = ChallengeDbHelper._internal();
  factory ChallengeDbHelper() => _instance;
  ChallengeDbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mandm_challenges.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

        -- Local progress fields
        is_completed INTEGER DEFAULT 0,
        is_unlocked INTEGER DEFAULT 0,
        time_spent INTEGER DEFAULT 0,
        user_points INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> insertChallenge(Challenge challenge) async {
    final db = await database;
    await db.insert(
      'challenges',
      challenge.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Challenge>> getChallengesByActivity(int activityId) async {
    final db = await database;
    final result = await db.query(
      'challenges',
      where: 'activity_id = ?',
      whereArgs: [activityId],
      orderBy: '"order" ASC',
    );
    return result.map((e) => Challenge.fromMap(e)).toList();
  }

  Future<void> updateChallenge(Challenge challenge) async {
    final db = await database;
    await db.update(
      'challenges',
      challenge.toMap(),
      where: 'id = ?',
      whereArgs: [challenge.id],
    );
  }

  Future<void> deleteAllChallenges() async {
    final db = await database;
    await db.delete('challenges');
  }

  Future<void> markChallengeCompleted(int id, int points, int timeSpent) async {
    final db = await database;
    await db.update(
      'challenges',
      {
        'is_completed': 1,
        'user_points': points,
        'time_spent': timeSpent,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> unlockNextChallenge(int currentOrder, int activityId) async {
    final db = await database;
    final result = await db.query(
      'challenges',
      where: '"order" = ? AND activity_id = ?',
      whereArgs: [currentOrder + 1, activityId],
    );
    if (result.isNotEmpty) {
      await db.update(
        'challenges',
        {'is_unlocked': 1},
        where: 'id = ?',
        whereArgs: [result.first['id']],
      );
    }
  }
}
