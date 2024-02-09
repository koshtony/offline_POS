import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Stocks {
  final String serial;
  final String name;
  final String category;
  final String desc;
  final double qty;
  final double cost;
  final double price;
  final double tax;
  final String image;

  Stocks(
      {required this.serial,
      required this.name,
      required this.category,
      required this.desc,
      required this.qty,
      required this.cost,
      required this.price,
      required this.tax,
      required this.image});

  Map<String, dynamic> toMap() {
    return {
      'serial': serial,
      'name': name,
      'category': category,
      'desc': desc,
      'qty': qty,
      'cost': cost,
      'price': price,
      'tax': tax,
      'image': image
    };
  }
}

class Bag {
  late int salesId;
  final String serial;
  final String name;
  final String category;
  final String desc;
  final int qty;
  final double price;
  final double tax;
  final double profit;
  final salesDate = DateFormat.yMMMEd().format(DateTime.now());
  final String? image;

  Bag({
    required this.salesId,
    required this.serial,
    required this.name,
    required this.category,
    required this.desc,
    required this.qty,
    required this.price,
    required this.tax,
    required this.profit,
    required this.image,
  });

  Bag.fromMap(Map<dynamic, dynamic> data)
      : salesId = data["salesId"],
        serial = data["serial"],
        name = data["name"],
        category = data["category"],
        desc = data["desc"],
        qty = data["qty"],
        price = data["price"],
        tax = data["tax"],
        profit = data["profit"],
        image = data["image"];

  Map<String, dynamic> toMap() {
    return {
      "salesId": salesId,
      "serial": serial,
      "name": name,
      "category": category,
      "desc": desc,
      "qty": qty,
      "price": price,
      "tax": tax,
      "profit": profit,
      "salesDate": salesDate,
      "image": image
    };
  }
}

class DashList {
  final String title;
  final double value;
  final double percentage;
  final Icon icon;
  final Color color;

  DashList(
      {required this.title,
      required this.value,
      required this.percentage,
      required this.icon,
      required this.color});
}
