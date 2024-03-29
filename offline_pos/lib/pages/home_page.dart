import 'package:flutter/material.dart';
import 'package:offline_pos/database/temporary.dart';
import 'package:offline_pos/pages/add_stocks_page.dart';
import 'package:offline_pos/pages/counter_page.dart';
import 'package:offline_pos/pages/dashboard.dart';
import 'package:offline_pos/pages/login.dart';
import 'package:offline_pos/pages/register_user.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String activePage = 'Home';

  renderView() {
    if (activePage == 'Home') {
      return const DashboardPage();
    } else if (activePage == 'Stocks') {
      return const AddStocksPage();
    } else if (activePage == 'Counter') {
      return const CounterPage();
    } else if (activePage == 'user') {
      return const RegisterUser();
    }
  }

  navigatePage(String pageName) {
    setState(() {
      activePage = pageName;
    });
  }

  Future getValByKey(key) async {
    return await PrefHelper.getValue(key);
  }

  String activeUser = '';
  @override
  void initState() {
    super.initState();
    getValByKey("username").then((value) {
      setState(() {
        activeUser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        actions: [
          ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.person),
              label: Text(activeUser)),
          IconButton(
            onPressed: () async {
              await PrefHelper.delVal("username");
              await PrefHelper.delVal("password");

              if (context.mounted) {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LoginPage()));
              }
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
          )
        ],
      ),
      body: Row(children: [
        Container(
            width: 70,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(16),
            child: sideBar()),
        Expanded(
            child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0xFF2A2D3E)),
          child: renderView(),
        ))
      ]),
    );
  }

  Widget sideBarList({required String pageName, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: GestureDetector(
        onTap: () => navigatePage(pageName),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: activePage == pageName ? Colors.green : Colors.blue),
                duration: const Duration(microseconds: 300),
                curve: Curves.slowMiddle,
                child: Column(
                  children: [
                    Icon(icon, color: Colors.white),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      pageName,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    )
                  ],
                ))),
      ),
    );
  }

  Widget sideBar() {
    return Column(
      children: [
        Expanded(
            child: ListView(
          children: [
            sideBarList(pageName: "Home", icon: Icons.dashboard),
            const SizedBox(
              height: 20,
            ),
            sideBarList(pageName: "Counter", icon: Icons.shopping_basket),
            const SizedBox(
              height: 20,
            ),
            sideBarList(pageName: "Stocks", icon: Icons.list),
            const SizedBox(
              height: 20,
            ),
            sideBarList(pageName: "user", icon: Icons.face_3_rounded),
            const SizedBox(height: 20),
          ],
        ))
      ],
    );
  }
}
