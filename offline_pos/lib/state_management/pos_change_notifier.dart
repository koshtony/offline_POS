import 'package:flutter/material.dart';
import 'package:flutter_shopping_cart/flutter_shopping_cart.dart';
import 'package:offline_pos/database/models.dart';
import 'package:offline_pos/database/operations.dart';

final SQLOps sqlops = SQLOps();

class PosChangeNotifier extends ChangeNotifier {
  List<Bag> cart = [];
  Future getStocks() async {
    notifyListeners();
    return await sqlops.getDetails('stocks');
  }

  Future getSales() async {
    notifyListeners();
    return await sqlops.getDetails('sales');
  }

  Future<List<Bag>> getCart() async {
    cart = await sqlops.getBagList();
    notifyListeners();
    return cart;
  }

  Future getIndStocks(String name) async {
    notifyListeners();
    return await sqlops.getIndDetail("stocks", name);
  }

  Future<num> getPriceTotal() async {
    notifyListeners();
    return await sqlops.getSum() ?? 0;
  }
}
