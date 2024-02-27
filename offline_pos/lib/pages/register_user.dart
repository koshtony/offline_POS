import 'package:flutter/material.dart';
import 'package:offline_pos/components/textbox.dart';
import 'package:offline_pos/database/models.dart';
import 'package:offline_pos/database/operations.dart';

class RegisterUser extends StatefulWidget {
  const RegisterUser({super.key});

  @override
  State<RegisterUser> createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final GlobalKey<FormState> _formKeys = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _password1Controller = TextEditingController();
  final _password2Controller = TextEditingController();
  bool hidden = true;
  String roleValue = "normal";
  var items = ["admin", "normal"];
  final SQLOps sqlops = SQLOps();
  void dispMsg(String msg, Color color) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(msg, style: TextStyle(color: color)),
          );
        });
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    return sqlops.getDetails("users");
  }

  Future<dynamic>? _usersList;

  @override
  void initState() {
    super.initState();
    _usersList = getAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF212332),
        body: SingleChildScrollView(
            child: SafeArea(
                child: Row(
          children: [
            Flexible(
                flex: 1,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                  child: Column(
                    children: [
                      Form(
                          key: _formKeys,
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              const Text(
                                "Add User",
                                style: TextStyle(color: Colors.orange),
                              ),
                              const SizedBox(height: 40),
                              TextBox(
                                  hint: "username",
                                  controller: _usernameController,
                                  initial: ""),
                              const SizedBox(height: 40),
                              TextBox(
                                  hint: "password",
                                  controller: _password1Controller,
                                  hidden: hidden,
                                  initial: ""),
                              const SizedBox(height: 40),
                              TextBox(
                                  hint: "confirm password",
                                  controller: _password2Controller,
                                  hidden: hidden,
                                  initial: ""),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        if (hidden == true) {
                                          setState(() {
                                            hidden = false;
                                          });
                                        } else if (hidden == false) {
                                          setState(() {
                                            hidden = true;
                                          });
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.visibility,
                                        color: Colors.green,
                                      )),
                                  const SizedBox(width: 40),
                                  DropdownButton(
                                      value: roleValue,
                                      icon: const Icon(
                                          Icons.keyboard_arrow_down_outlined),
                                      items: items.map((items) {
                                        return DropdownMenuItem(
                                          value: items,
                                          child: Text(items,
                                              style: const TextStyle(
                                                  color: Colors.orange)),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          roleValue = value!;
                                        });
                                      })
                                ],
                              ),
                              const SizedBox(
                                height: 40,
                              ),
                              ElevatedButton.icon(
                                  onPressed: () async {
                                    final List<Map<String, dynamic>>
                                        checkUsername = await sqlops.getUser(
                                            _usernameController.text
                                                .toString());
                                    final User user = User(
                                        username: _usernameController.text,
                                        password: _password1Controller.text,
                                        role: roleValue);
                                    if (_formKeys.currentState!.validate()) {
                                      if (_password1Controller.text !=
                                          _password2Controller.text) {
                                        dispMsg("password not matching",
                                            Colors.red);
                                      } else if (checkUsername.isNotEmpty) {
                                        dispMsg(
                                            "User already exists", Colors.red);
                                      } else {
                                        await sqlops.createUser(user);
                                        dispMsg("user created successfully",
                                            Colors.green);
                                      }
                                    }
                                  },
                                  icon: const Icon(
                                      Icons.app_registration_rounded),
                                  label: const Text("register"))
                            ],
                          ))
                    ],
                  ),
                )),
            Flexible(
                flex: 1,
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    const Text("Users List",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top,
                      child: FutureBuilder(
                          future: _usersList,
                          builder: ((context, snapshot) {
                            if (snapshot.data == null) {
                              const Text("no users");
                            } else if (snapshot.hasData) {
                              return ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: snapshot.data?.length ?? 0,
                                  itemBuilder: ((context, index) {
                                    return ListTile(
                                      tileColor: Colors.grey,
                                      leading: const Icon(
                                          Icons.verified_user_rounded),
                                      title: Text(
                                          snapshot.data[index]["username"]),
                                      subtitle:
                                          Text(snapshot.data[index]["role"]),
                                      trailing: IconButton(
                                          onPressed: () {},
                                          icon: const Icon(Icons.delete)),
                                    );
                                  }));
                            } else if (snapshot.hasError) {
                              return const Text("no data");
                            }

                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          })),
                    )
                  ],
                ))
          ],
        ))));
  }
}
