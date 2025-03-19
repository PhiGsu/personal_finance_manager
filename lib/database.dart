import 'package:path/path.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  // Make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    return _database ??= await _init();
  }

  // this opens the database (and creates it if it doesn't exist)
  Future<Database> _init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // This deletes the database
  Future<void> deleteDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    await deleteDatabase(path);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Category (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      );'''
    );

    await db.execute('''
      CREATE TABLE Goal (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,  
        target_amount NUMERIC NOT NULL,
        current_amount NUMERIC DEFAULT 0,
        due_date DATE,         
        category_id INTEGER,    
        FOREIGN KEY (category_id) REFERENCES Category(id)
      );'''
    );

    await db.execute('''
      CREATE TABLE UserTransaction (
        id INTEGER PRIMARY KEY,
        date DATE,
        cost NUMERIC NOT NULL,
        description TEXT,
        category_id INTEGER,
        FOREIGN KEY (category_id) REFERENCES Category(id)
      );'''
    );

    // Default Categories
    await db.insert('Category', {'name': 'Income'});
    await db.insert('Category', {'name': 'Debt'});
    await db.insert('Category', {'name': 'Food'});
    await db.insert('Category', {'name': 'Rent'});
    await db.insert('Category', {'name': 'Entertainment'});
    await db.insert('Category', {'name': 'Utilities'});
    await db.insert('Category', {'name': 'Health'});
    await db.insert('Category', {'name': 'Shopping'});
    await db.insert('Category', {'name': 'Miscellaneous'});
  }

  // Helper methods
  // Inserts a row in the database where each key in the
  // Map is a column name
  // and the value is the column value. The return value
  // is the id of the
  // inserted row.
  // Helper methods
  // Inserts a row in the database where each key in the
  // Map is a column name
  // and the value is the column value. The return value
  // is the id of the
  // inserted row.
  Future<int> insert(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.
  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    Database db = await instance.database;
    return await db.query(table);
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryRowCount(String table) async {
    Database db = await instance.database;
    final results = await db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> update(String table, Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update(
      table,
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> delete(String table, int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Returns categories with its id as the key and its name as the value
  Future<Map<int, String>> getCategories() async {
    Database db = await instance.database;
    Map<int, String> categories = {};

    final List<Map<String, dynamic>> results = await db.query('Category');
    for (var category in results) {
      categories[category['id']] = category['name'];
    }
    return categories;
  }

  // Returns transactions sorted by date descending
  Future<List<UserTransaction>> getTransactions() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'UserTransaction',
      orderBy: 'date DESC',
    );

    return results
        .map((transaction) => UserTransaction(
              id: transaction['id'],
              date: DateTime.parse(transaction['date']),
              cost: (transaction['cost'] as num).toDouble(),
              description: transaction['description'] ?? '',
              categoryId: transaction['category_id'] ?? 0,
            ))
        .toList();
  }
}
