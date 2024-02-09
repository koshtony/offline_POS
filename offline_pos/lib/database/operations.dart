import 'package:flutter/material.dart';
import 'package:offline_pos/database/models.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class SQLOps {
  static Future<void> createTables(Database database) async {
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

       """);
  }

  static Future<Database> _db() async {
    //WidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    final factory = databaseFactoryFfiWeb;

    return factory.openDatabase('pos_db.db',
        options: OpenDatabaseOptions(
            version: 1,
            onCreate: (Database database, int version) async {
              await createTables(database);
            }));
  }

  static Future<int> addDetails(Stocks stock, String table) async {
    final db = await SQLOps._db();

    final op = await db.insert(table, stock.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return op;
  }

  static Future<int> addToCart(Bag cart, String table) async {
    final db = await SQLOps._db();

    final op = await db.insert(table, cart.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return op;
  }

  static Future<int> addToSales(Bag cart, String table) async {
    final db = await SQLOps._db();

    final op = await db.insert(table, cart.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    return op;
  }

  static Future<List<Map<String, dynamic>>> getDetails(String table) async {
    final db = await SQLOps._db();

    return db.query(table);
  }

  static Future<List<Bag>> getBagList() async {
    var db = await SQLOps._db();
    final List<Map<String, Object?>> result = await db.query('cart');

    return result.map((result) => Bag.fromMap(result)).toList();
  }

  static Future<List<Map<String, dynamic>>> getIndDetail(
      String table, String name) async {
    final db = await SQLOps._db();
    return db.query(table, where: "name LIKE ?", whereArgs: ['%$name%']);
  }

  static Future<int> updateQty(int id, int qty) async {
    final db = await SQLOps._db();

    final newQty = {'qty': qty};

    return db.update('cart', newQty, where: "salesId=?", whereArgs: [id]);
  }

  static Future<int> updateStockQty(int id, int qty) async {
    final db = await SQLOps._db();

    final newQty = {'qty': qty};

    return db.update("stocks", newQty, where: "id=?", whereArgs: [id]);
  }

  static Future<int> subtractStock(int id, int qty) async {
    final db = await SQLOps._db();
    List<Map> results =
        await db.rawQuery("SELECT qty FROM stocks where id=?", [id]);
    int oldQty = results[0]["qty"];

    final newQty = {'qty': oldQty - qty};

    return db.update('stocks', newQty, where: "id=?", whereArgs: [id]);
  }

  static Future<void> deleteItem(int id, String table) async {
    final db = await SQLOps._db();

    await db.delete(
      table,
      where: "salesId=?",
      whereArgs: [id],
    );
  }

//  sum qty of per category on given time range
  static Future<List<Map<String, dynamic>>> groupByCat() async {
    final db = await SQLOps._db();

    return db.rawQuery(
        "select category, sum(qty) as sumQty from stocks group by category");
  }

// sum overall qty, price, profit on given time range

  static Future<int> getTotals(String col, String date1, String date2) async {
    final db = await SQLOps._db();

    List<Map> result = await db.rawQuery(
        "SELECT salesDate,SUM($col) AS totals FROM sales WHERE salesDate >='$date1' ");

    int total = result[0]["totals"];

    return total;
  }

  static Future<int> getMonthTotals(String col, String date1) async {
    final db = await SQLOps._db();

    List<Map> result = await db.rawQuery(
      "SELECT SUM($col) AS totals FROM sales WHERE salesDate >='$date1'",
    );

    int total = result[0]["totals"];

    return total;
  }

  static Future<int> getSum() async {
    final db = await SQLOps._db();

    List<Map> result =
        await db.rawQuery("select sum(price*qty) as totalPrice from cart");
    int sum = result[0]['totalPrice'];
    return sum;
  }

  static Future<int> getStocksQtyTotal() async {
    final db = await SQLOps._db();

    List<Map> result =
        await db.rawQuery("select sum(qty) as totalQty from stocks");
    int total = result[0]['totalQty'];

    return total;
  }

  static Future<int> getStocksValTotal(col) async {
    final db = await SQLOps._db();

    List<Map> result =
        await db.rawQuery("select sum($col*qty) as totalVal from stocks");
    int total = result[0]['totalVal'];

    return total;
  }
}

//
