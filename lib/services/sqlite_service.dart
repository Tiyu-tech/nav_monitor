import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  Future<void> InitDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'nav_monitor.db');

    // Open and initialize DB with corrected SQL syntax
    await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE project (
          project_id TEXT PRIMARY KEY,
          project_name TEXT,
          org_id TEXT,
          start_date TEXT,
          end_date TEXT
        )
      ''');

        await db.execute('''
        CREATE TABLE activity (
        activity_id TEXT PRIMARY KEY,
        activity_name TEXT,
        start_date TEXT,
        end_date TEXT,
        project_id TEXT,
        FOREIGN KEY (project_id) REFERENCES project(project_id)
        )
      ''');

        await db.execute('''
        CREATE TABLE question (
          question_id TEXT PRIMARY KEY,
          question TEXT,
          question_ans_type TEXT,
          question_count INTEGER,
          project_id TEXT,
          activity_id TEXT,
          FOREIGN KEY (project_id) REFERENCES project(project_id),
          FOREIGN KEY (activity_id) REFERENCES activity(activity_id)
        )
      ''');

        await db.execute('''
        CREATE TABLE answer (
          answer TEXT,
          status INTEGER DEFAULT 0,
          answer_count INTEGER,
          answer_id TEXT PRIMARY KEY,
          org_id TEXT,
          trans_date TEXT,
          synced INTEGER DEFAULT 0,
          question_id TEXT,
          activity_id TEXT,
          FOREIGN KEY (question_id) REFERENCES question(question_id),
          FOREIGN KEY (activity_id) REFERENCES activity(activity_id)
          
        )
      ''');
      },
    );

    print('[InitDatabase] Database initialized successfully.');
  }

//Define function vor batch  insertion of projects
  Future<void> insertAnswer(List<Map<String, dynamic>> answers) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'nav_monitor.db'),
    );

    final batch = db.batch();
    for (var answer in answers) {
      batch.insert(
        'answer',
        {
          'answer_id': answer['answer_id'],
          'answer': answer['answer'],
          'org_id': answer['org_id'],
          'trans_date': answer['trans_date'],
          'question_id': answer['question_id'],
          'activity_id': answer['activity_id'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // overwrite if exists
      );
    }
  }

  Future<void> insertProject(List<Map<String, dynamic>> projects) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'nav_monitor.db'),
    );

    final batch = db.batch();
    for (var project in projects) {
      batch.insert(
        'project',
        {
          'project_id': project['project_id'],
          'project_name': project['project_name'],
          'org_id': project['org_id'],
          'start_date': project['start_date'],
          'end_date': project['end_date'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // overwrite if exists
      );
    }

    await batch.commit(noResult: true); // commit all insertions
  }

// Define function for batch insertion of activities
  Future<void> insertActivity(List<Map<String, dynamic>> activities) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'nav_monitor.db'),
    );

    final batch = db.batch();
    for (var activity in activities) {
      batch.insert(
        'activity',
        {
          'activity_id': activity['activity_id'],
          'activity_name': activity['activity_name'],
          'project_id': activity['project_id'],
          'start_date': activity['start_date'],
          'end_date': activity['end_date'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // overwrite if exists
      );
    }

    await batch.commit(noResult: true); // commit all insertions
  }

// Define function for batch insertion of questions
  Future<void> insertQuestion(List<Map<String, dynamic>> questions) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'nav_monitor.db'),
    );

    final batch = db.batch();
    for (var question in questions) {
      batch.insert(
        'question',
        {
          'question_id': question['question_id'],
          'question_ans_type': question['question_ans_type'],
          'question': question['question'],
          'project_id': question['project_id'],
          'activity_id': question['activity_id'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace, // overwrite if exists
      );
    }

    await batch.commit(noResult: true); // commit all insertions
  }

  //function to read projects from the database
  Future<List<Map<String, dynamic>>> getAllProjects() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'nav_monitor.db'),
    );

    final List<Map<String, dynamic>> projects =
        await db.rawQuery('SELECT * FROM project');
    return projects;
  }

  //function to read activities from the database
  Future<List<Map<String, dynamic>>> getActivities() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'nav_monitor.db'),
    );

    final List<Map<String, dynamic>> activities =
        await db.rawQuery('SELECT * FROM activity');
    return activities;
  }

  //function to read questions from the database
  Future<List<Map<String, dynamic>>> getQuestions() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'nav_monitor.db'),
    );

    final List<Map<String, dynamic>> questions =
        await db.rawQuery('SELECT * FROM question');
    return questions;
  }

  Future<void> deleteDatabaseFile() async {
    String path = join(await getDatabasesPath(), 'nav_monitor.db');
    await deleteDatabase(path);
    print('[DatabaseService] Database file deleted completely.');
  }

  Future<void> clearDatabase() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'nav_monitor.db'),
    );

    // Delete all rows from each table
    await db.delete('answer');
    await db.delete('question');
    await db.delete('activity');
    await db.delete('project');

    print('[DatabaseService] All tables cleared.');
  }
}
