import 'dart:io';

import 'package:offline_pos/database/models.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SQLOps {
  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDB();
    return _db!;
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute("""
        CREATE TABLE IF NOT EXISTS stocks(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serial TEXT, name TEXT, category TEXT, desc TEXT, qty DOUBLE,
          cost DOUBLE, price DOUBLE, tax DOUBLE, image TEXT

        );

        CREATE TABLE IF NOT EXISTS sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          salesId INTEGER,
          serial TEXT, name TEXT, category TEXT, desc TEXT, qty DOUBLE,
          price DOUBLE, tax DOUBLE,profit double, salesDate DATE, image TEXT

        );

        CREATE TABLE IF NOT EXISTS cart(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          salesId INTEGER,
          serial TEXT, name TEXT, category TEXT, desc TEXT, qty DOUBLE,
          price DOUBLE, tax DOUBLE,profit double, salesDate DATE, image TEXT

        );

        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT,
          password TEXT,
          role TEXT
        );

       """);
  }

  Future<Database> initDB() async {
    //WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocumentsDir.path, "pos_db.db");
      final winLinuxDB = await databaseFactory.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _onCreate,
        ),
      );
      return winLinuxDB;
    } else if (Platform.isAndroid || Platform.isIOS) {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, "pos_db.db");
      final iOSAndroidDB = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
      return iOSAndroidDB;
    }
    throw Exception("Unsupported platform");
  }

  Future<int> createUser(User user) async {
    final db = await database;

    final op = await db.insert("users", user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return op;
  }

  Future<List<Map<String, dynamic>>> getUser(String name) async {
    final db = await database;
    return db.query("users", where: "username=?", whereArgs: [name]);
  }

  Future<int> addDetails(Stocks stock, String table) async {
    final db = await database;

    final op = await db.insert(table, stock.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return op;
  }

  Future<int> addToCart(Bag cart, String table) async {
    final db = await database;

    final op = await db.insert(table, cart.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return op;
  }

  Future<int> addToSales(Bag cart, String table) async {
    final db = await database;

    final op = await db.insert(table, cart.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return op;
  }

  Future<List<Map<String, dynamic>>> getDetails(String table) async {
    final db = await database;

    return db.query(table);
  }

  Future<List<Bag>> getBagList() async {
    var db = await database;
    final List<Map<String, Object?>> result = await db.query('cart');

    return result.map((result) => Bag.fromMap(result)).toList();
  }

  Future<List<Map<String, dynamic>>> getIndDetail(
      String table, String name) async {
    final db = await database;
    return db.query(table, where: "name LIKE ?", whereArgs: ['%$name%']);
  }

  Future<List<Map<String, dynamic>>> getDateDetails(
      String table, String name) async {
    final db = await database;
    return db.query(table, where: "salesDate LIKE ?", whereArgs: ['%$name%']);
  }

  Future<int> updateQty(int id, num qty) async {
    final db = await database;

    final newQty = {'qty': qty};

    return db.update('cart', newQty, where: "salesId=?", whereArgs: [id]);
  }

  Future<int> updateStockQty(int id, num qty) async {
    final db = await database;

    final newQty = {'qty': qty};

    return db.update("stocks", newQty, where: "id=?", whereArgs: [id]);
  }

  Future<int> subtractStock(int id, num qty) async {
    final db = await database;
    List<Map> results =
        await db.rawQuery("SELECT qty FROM stocks where id=?", [id]);
    num oldQty = results[0]["qty"];

    final newQty = {'qty': oldQty - qty};

    return db.update('stocks', newQty, where: "id=?", whereArgs: [id]);
  }

  Future<void> deleteItem(int id, String table) async {
    final db = await database;

    await db.delete(
      table,
      where: "salesId=?",
      whereArgs: [id],
    );
  }

//  sum qty of per category on given time range
  Future<List<Map<String, dynamic>>> groupByCat() async {
    final db = await database;

    return db.rawQuery(
        "select category, sum(qty) as sumQty from stocks group by category");
  }

  Future<List<Map<String, dynamic>>> groupFilterByCat(category) async {
    final db = await database;

    return db.rawQuery(
        "select category, sum(qty) as sumQty from stocks  WHERE category LIKE ? group by category",
        ['%$category%']);
  }

// sum overall qty, price, profit on given time range

  Future<double> getTotals(String col, String date1, String date2) async {
    final db = await database;

    List<Map> result = await db.rawQuery(
        "SELECT salesDate,SUM($col) AS totals FROM sales WHERE salesDate >='$date1' ");

    double total = result[0]["totals"];

    return total;
  }

  Future<double> getMonthTotals(String col, String date1) async {
    final db = await database;

    List<Map> result = await db.rawQuery(
      "SELECT SUM($col) AS totals FROM sales WHERE salesDate >='$date1'",
    );

    double total = result[0]["totals"];

    return total;
  }

  Future<List> getSummary(String date1) async {
    final db = await database;

    List<Map<String, dynamic>> summary = await db.rawQuery(
        "SELECT SUM(qty) AS sumQty, SUM(price) AS sumPrice, SUM(profit) AS sumProfit, SUM(tax) AS sumTax FROM sales WHERE salesDate >= ?",
        [date1]);

    List listSummary = [
      summary[0]["sumQty"].toStringAsFixed(2),
      summary[0]["sumPrice"],
      summary[0]["sumProfit"].toStringAsFixed(2),
      (summary[0]["sumTax"] * summary[0]["sumPrice"]).toStringAsFixed(2),
    ];
    return listSummary;
  }

  Future<List?> getDateSummary(String date1) async {
    final db = await database;

    List<Map<String, dynamic>> summary = await db.rawQuery(
        "SELECT SUM(qty) AS sumQty, SUM(price) AS sumPrice, SUM(profit) AS sumProfit, SUM(tax*price) AS sumTax FROM sales WHERE salesDate LIKE ?",
        ['%$date1%']);

    List? listSummary = [
      summary[0]["sumQty"] ?? 0,
      summary[0]["sumPrice"] ?? 0,
      summary[0]["sumProfit"] ?? 0,
      summary[0]["sumTax"] ?? 0,
    ];
    return listSummary;
  }

  Future<num?> getSum() async {
    final db = await database;

    List<Map> result =
        await db.rawQuery("select sum(price*qty) as totalPrice from cart");
    num? sum = result[0]['totalPrice'];

    return sum ?? 0;
  }

  Future<num?> getStocksQtyTotal() async {
    final db = await database;

    List<Map> result =
        await db.rawQuery("select sum(qty) as totalQty from stocks");
    num? total = result[0]['totalQty'];

    return total ?? 0;
  }

  Future<num?> getStocksValTotal(col) async {
    final db = await database;

    List<Map> result =
        await db.rawQuery("select sum($col*qty) as totalVal from stocks");
    num? total = result[0]['totalVal'];

    return total ?? 0;
  }
}

//
