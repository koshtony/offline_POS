import 'package:flutter/material.dart';
import 'package:offline_pos/components/textbox.dart';
import 'package:offline_pos/database/models.dart';
import 'package:offline_pos/database/operations.dart';
import 'package:offline_pos/state_management/pos_change_notifier.dart';
import 'package:provider/provider.dart';

class AddStocksPage extends StatefulWidget {
  const AddStocksPage({super.key});

  @override
  State<AddStocksPage> createState() => _AddStocksPageState();
}

class _AddStocksPageState extends State<AddStocksPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final serialController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descController = TextEditingController();
  final _qtyController = TextEditingController();
  final _costController = TextEditingController();
  final _priceController = TextEditingController();
  final _taxController = TextEditingController();
  final SQLOps sqlops = SQLOps();
  Future<void> saveStocks() async {
    final Stocks stock = Stocks(
        serial: serialController.text,
        name: _nameController.text,
        category: _categoryController.text,
        desc: _descController.text,
        qty: double.parse(_qtyController.text),
        cost: double.parse(_costController.text),
        price: double.parse(_priceController.text),
        tax: double.parse(_taxController.text),
        image: '');

    await sqlops.addDetails(stock, 'stocks');
  }

  Future<dynamic>? _stockList;

  TextEditingController editingController = TextEditingController();

  void retMsg(String msg, Color color) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(msg, style: TextStyle(color: color)),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    _stockList = context.read<PosChangeNotifier>().getStocks();
    print(_stockList);
  }

  void filterStockList(String query) {
    setState(() {
      _stockList = context.read<PosChangeNotifier>().getIndStocks(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black38,
        title: const Center(
          child: Text(
            "Add Stocks",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Flexible(
                flex: 1,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top,
                  child: Column(
                    children: [
                      const Icon(Icons.storefront, size: 50),
                      const SizedBox(height: 25),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextBox(
                                  hint: "Serial Number",
                                  controller: serialController,
                                  initial: ""),
                              const SizedBox(height: 15),
                              TextBox(
                                hint: "Name",
                                controller: _nameController,
                                initial: "",
                              ),
                              const SizedBox(height: 15),
                              TextBox(
                                  hint: "Category",
                                  controller: _categoryController,
                                  initial: ""),
                              const SizedBox(height: 15),
                              TextBox(
                                  hint: "Desc",
                                  controller: _descController,
                                  initial: ""),
                              const SizedBox(height: 15),
                              TextBox(
                                hint: "Qty",
                                controller: _qtyController,
                                initial: 1,
                              ),
                              const SizedBox(height: 15),
                              TextBox(
                                hint: "Cost",
                                controller: _costController,
                                initial: 0.0,
                              ),
                              const SizedBox(height: 15),
                              TextBox(
                                hint: "Price",
                                controller: _priceController,
                                initial: 0.0,
                              ),
                              const SizedBox(height: 15),
                              TextBox(
                                  hint: "Tax",
                                  controller: _taxController,
                                  initial: 0.16),
                              const SizedBox(height: 15),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ElevatedButton.icon(
                                        onPressed: () async {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            await saveStocks();

                                            setState(() {
                                              _stockList = context
                                                  .read<PosChangeNotifier>()
                                                  .getStocks();
                                            });

                                            retMsg("saved successfully",
                                                Colors.green);
                                          }
                                        },
                                        icon: const Icon(Icons.save),
                                        label: const Text("save")),
                                    const SizedBox(width: 20),
                                    ElevatedButton.icon(
                                        onPressed: () {},
                                        icon: const Icon(Icons.update),
                                        label: const Text("Update"))
                                  ]),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    TextField(
                      controller: editingController,
                      onChanged: (value) {
                        if (value == "") {
                          _stockList =
                              context.read<PosChangeNotifier>().getStocks();
                        } else {
                          filterStockList(value.toString());
                        }
                      },
                      decoration: InputDecoration(
                          labelText: "Search",
                          hintText: "Search",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)))),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top,
                      child: FutureBuilder(
                          future: _stockList,
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              const Text("no data");
                            } else if (snapshot.hasData) {
                              return ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: snapshot.data?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      color: Colors.grey,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  RichText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      text: TextSpan(
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueGrey
                                                                  .shade800,
                                                              fontSize: 12.0,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          children: [
                                                            TextSpan(
                                                                text: snapshot
                                                                    .data[index]
                                                                        ["name"]
                                                                    .toString())
                                                          ])),
                                                  const SizedBox(width: 40),
                                                  RichText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      text: TextSpan(
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueGrey
                                                                  .shade800,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12.0),
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                    '${snapshot.data[index]["category"]}')
                                                          ])),
                                                  const SizedBox(width: 40),
                                                  RichText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      text: TextSpan(
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueGrey
                                                                  .shade800,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12.0),
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                    '${snapshot.data[index]["desc"]}')
                                                          ])),
                                                  const SizedBox(width: 40),
                                                  RichText(
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      text: TextSpan(
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .blueGrey
                                                                  .shade800,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12.0),
                                                          children: [
                                                            TextSpan(
                                                                text:
                                                                    'ksh ${snapshot.data[index]["cost"]}')
                                                          ]))
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                                child: Wrap(children: [
                                              IconButton(
                                                  onPressed: () async {
                                                    await sqlops.updateStockQty(
                                                        snapshot.data[index]
                                                            ["id"],
                                                        snapshot.data[index]
                                                                ["qty"] +
                                                            1);

                                                    setState(() {
                                                      _stockList = context
                                                          .read<
                                                              PosChangeNotifier>()
                                                          .getStocks();
                                                    });
                                                  },
                                                  icon: const Icon(Icons.add)),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(snapshot.data[index]["qty"]
                                                  .toString()),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              IconButton(
                                                  onPressed: () async {
                                                    await sqlops.updateStockQty(
                                                        snapshot.data[index]
                                                            ["id"],
                                                        snapshot.data[index]
                                                                ["qty"] -
                                                            1);

                                                    setState(() {
                                                      _stockList = context
                                                          .read<
                                                              PosChangeNotifier>()
                                                          .getStocks();
                                                    });
                                                  },
                                                  icon:
                                                      const Icon(Icons.remove)),
                                              ElevatedButton.icon(
                                                  onPressed: () {
                                                    setState(() {
                                                      serialController.text =
                                                          snapshot.data[index]
                                                                  ["serial"]
                                                              .toString();
                                                      _nameController.text =
                                                          snapshot.data[index]
                                                                  ["name"]
                                                              .toString();
                                                      _categoryController.text =
                                                          snapshot.data[index]
                                                                  ["category"]
                                                              .toString();

                                                      _descController.text =
                                                          snapshot.data[index]
                                                                  ["desc"]
                                                              .toString();
                                                      _qtyController.text =
                                                          snapshot.data[index]
                                                                  ["qty"]
                                                              .toString();

                                                      _priceController.text =
                                                          snapshot.data[index]
                                                                  ["price"]
                                                              .toString();
                                                      _costController.text =
                                                          snapshot.data[index]
                                                                  ["cost"]
                                                              .toString();
                                                      _taxController.text =
                                                          snapshot.data[index]
                                                                  ["tax"]
                                                              .toString();
                                                    });
                                                  },
                                                  icon:
                                                      const Icon(Icons.update),
                                                  label: const Text(""))
                                            ])),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            } else if (snapshot.hasError) {
                              return const Text("Data cannot be loaded");
                            }
                            return const CircularProgressIndicator();
                          }),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
