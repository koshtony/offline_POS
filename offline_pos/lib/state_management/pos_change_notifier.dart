import 'package:flutter/material.dart';
import 'package:flutter_shopping_cart/flutter_shopping_cart.dart';
import 'package:offline_pos/database/models.dart';
import 'package:offline_pos/database/operations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PosChangeNotifier extends ChangeNotifier {
  List<Bag> cart = [];
  Future getStocks() async {
    notifyListeners();
    return await SQLOps.getDetails('stocks');
  }

  Future getSales() async {
    notifyListeners();
    return await SQLOps.getDetails('sales');
  }

  Future<List<Bag>> getCart() async {
    cart = await SQLOps.getBagList();
    notifyListeners();
    return cart;
  }

  Future getIndStocks(String name) async {
    notifyListeners();
    return await SQLOps.getIndDetail("stocks", name);
  }

  Future<int> getPriceTotal() async {
    notifyListeners();
    return await SQLOps.getSum();
  }
}
