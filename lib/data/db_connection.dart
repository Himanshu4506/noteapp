import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper getInstance = DBHelper._internal();
  DBHelper._internal();

  static Database? _db;

  static const String TABLE_NAME = "notes";
  static const String COLUMN_ID = "id";
  static const String COLUMN_TITLE = "title";
  static const String COLUMN_DESC = "desc";

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), "notes.db");

    return await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        await database.execute("""
          CREATE TABLE $TABLE_NAME (
            $COLUMN_ID INTEGER PRIMARY KEY AUTOINCREMENT,
            $COLUMN_TITLE TEXT,
            $COLUMN_DESC TEXT
          )
        """);
      },
    );
  }

  // INSERT NOTE
  Future<bool> addNote({required String title, required String desc}) async {
    var dbClient = await db;
    int result = await dbClient.insert(TABLE_NAME, {
      COLUMN_TITLE: title,
      COLUMN_DESC: desc,
    });

    return result > 0;
  }

  // GET ALL NOTES
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var dbClient = await db;
    return await dbClient.query(TABLE_NAME);
  }

  // UPDATE NOTE
  Future<bool> updateNote({
    required int sno,
    required String title,
    required String desc,
  }) async {
    var dbClient = await db;

    int result = await dbClient.update(
      TABLE_NAME,
      {
        COLUMN_TITLE: title,
        COLUMN_DESC: desc,
      },
      where: "$COLUMN_ID = ?",
      whereArgs: [sno],
    );

    return result > 0;
  }

  // DELETE NOTE
  Future<bool> deleteNote({required int sno}) async {
    var dbClient = await db;

    int result = await dbClient.delete(
      TABLE_NAME,
      where: "$COLUMN_ID = ?",
      whereArgs: [sno],
    );

    return result > 0;
  }
}
