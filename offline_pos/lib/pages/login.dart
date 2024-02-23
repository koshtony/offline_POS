import 'package:flutter/material.dart';
import 'package:offline_pos/components/textbox.dart';
import 'package:offline_pos/database/operations.dart';
import 'package:offline_pos/database/temporary.dart';
import 'package:offline_pos/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKeys = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void retMsg(String msg, Color color) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(msg, style: TextStyle(color: color)),
          );
        });
  }

  Future getValByKey(key) async {
    return await PrefHelper.getValue(key);
  }

  @override
  void initState() {
    super.initState();
    getValByKey("username").then((value) {
      setState(() {
        usernameController.text = value;
      });
    });
    getValByKey("password").then((value) {
      setState(() {
        passwordController.text = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/background.png'), fit: BoxFit.cover),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 360, right: 360),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.face,
                  size: 100,
                  color: Colors.orange,
                ),
                const SizedBox(height: 40),
                Form(
                    key: _formKeys,
                    child: Column(children: [
                      TextBox(
                          hint: "username",
                          controller: usernameController,
                          initial: ""),
                      const SizedBox(height: 40),
                      TextBox(
                          hint: "password",
                          controller: passwordController,
                          initial: "",
                          hidden: true),
                      const SizedBox(height: 40),
                      ElevatedButton.icon(
                          onPressed: () async {
                            if (_formKeys.currentState!.validate()) {
                              final List<Map<String, dynamic>> getUsername =
                                  await SQLOps.getUser(usernameController.text);
                              if (getUsername.isNotEmpty == true &&
                                  getUsername[0]["password"] ==
                                      passwordController.text) {
                                if (context.mounted) {
                                  PrefHelper.saveUserName(
                                      "username", usernameController.text);
                                  PrefHelper.saveUserName(
                                      "password", passwordController.text);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                                }
                              } else {
                                retMsg("Invalid Username or password",
                                    Colors.green);
                              }
                            }
                          },
                          icon: const Icon(Icons.login),
                          label: const Text("login"))
                    ]))
              ],
            ),
          )),
    ));
  }
}
