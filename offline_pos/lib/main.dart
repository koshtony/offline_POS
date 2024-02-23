import 'package:flutter/material.dart';
import 'package:offline_pos/pages/add_stocks_page.dart';
import 'package:offline_pos/pages/home_page.dart';
import 'package:offline_pos/pages/login.dart';
import 'package:offline_pos/state_management/pos_change_notifier.dart';
import 'package:flutter_shopping_cart/flutter_shopping_cart.dart';
import 'package:provider/provider.dart';

void main() async {
  await ShoppingCart().init();
  runApp(
    ChangeNotifierProvider(
        create: (context) => PosChangeNotifier(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
