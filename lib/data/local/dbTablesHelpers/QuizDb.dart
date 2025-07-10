import 'package:mandm/models/quiz_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class QuizDbHelper {
  static final QuizDbHelper _instance = QuizDbHelper._internal();
  factory QuizDbHelper() => _instance;
  QuizDbHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mandm_quizzes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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

        -- Local tracking fields
        is_completed INTEGER DEFAULT 0,
        is_unlocked INTEGER DEFAULT 0,
        user_selected TEXT
      )
    ''');
  }

  Future<void> insertQuiz(Quiz quiz) async {
    final db = await database;
    await db.insert(
      'quizzes',
      quiz.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Quiz>> getQuizzesByChallenge(int challengeId) async {
    final db = await database;
    final result = await db.query(
      'quizzes',
      where: 'challenge_id = ?',
      whereArgs: [challengeId],
    );
    return result.map((e) => Quiz.fromMap(e)).toList();
  }

  Future<void> updateQuiz(Quiz quiz) async {
    final db = await database;
    await db.update(
      'quizzes',
      quiz.toMap(),
      where: 'id = ?',
      whereArgs: [quiz.id],
    );
  }

  Future<void> markQuizCompleted(int id, String selectedAnswer) async {
    final db = await database;
    await db.update(
      'quizzes',
      {
        'is_completed': 1,
        'user_selected': selectedAnswer,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> unlockNextQuiz(int currentId, int challengeId) async {
    final db = await database;

    final result = await db.query(
      'quizzes',
      where: 'challenge_id = ? AND id > ?',
      whereArgs: [challengeId, currentId],
      orderBy: 'id ASC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      final nextId = result.first['id'];
      await db.update(
        'quizzes',
        {'is_unlocked': 1},
        where: 'id = ?',
        whereArgs: [nextId],
      );
    }
  }

  Future<void> deleteAllQuizzes() async {
    final db = await database;
    await db.delete('quizzes');
  }
}
