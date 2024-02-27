import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:flutter_shopping_cart/flutter_shopping_cart.dart';
import 'package:offline_pos/database/models.dart';
import 'package:offline_pos/database/operations.dart';
import 'package:offline_pos/state_management/pos_change_notifier.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

final SQLOps sqlops = SQLOps();

class _CounterPageState extends State<CounterPage> {
  Future getStocks() async {
    return await sqlops.getDetails('stocks');
  }

  Future getIndStocks(id) async {
    return await sqlops.getIndDetail("stocks", id);
  }

  Future getTotal() async {
    return await sqlops.getSum() ?? 0;
  }

  Future<List<Bag>> getCartItems() async {
    return await sqlops.getBagList();
  }

  Future getVat() async {
    return await sqlops.getSum() ?? 0 * 1;
  }

  Future<dynamic>? _stocksList;

  Future<dynamic>? _total;

  late num _totals = 0;

  Future<dynamic>? _vat;

  late num _vats = 0;

  late List<Bag> cartItems = [];

  var shoppingCart = ShoppingCart();

  TextEditingController searchController = TextEditingController();

  void showAlert(String msg) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(
            msg,
            style: const TextStyle(
              fontSize: 12,
            ),
          ));
        });
  }

  @override
  void initState() {
    super.initState();
    _stocksList = getStocks();
    context.read<PosChangeNotifier>().getCart();
    _total = getTotal();
    _vat = getVat();

    getCartItems().then((value) {
      setState(() {
        cartItems = value;
      });
    });

    getTotal().then((value) {
      setState(() {
        _totals = value;
        _vats = value * 0.16;

        //vat = value * 0.16;
      });
    });
  }

  void filterStockList(String query) {
    setState(() {
      _stocksList = context.read<PosChangeNotifier>().getIndStocks(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<PosChangeNotifier>(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.top,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text("Items List",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
                    TextField(
                      controller: searchController,
                      onChanged: ((value) {
                        if (value == "") {
                          _stocksList =
                              context.read<PosChangeNotifier>().getStocks();
                        } else {
                          filterStockList(value.toString());
                        }
                      }),
                      decoration: InputDecoration(
                          labelText: "search",
                          prefixIcon: Icon(Icons.search),
                          prefixIconColor: Colors.orange,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          )),
                    ),
                    const SizedBox(height: 40),
                    FutureBuilder(
                        future: _stocksList,
                        builder: ((context, snapshot) {
                          if (snapshot.data == null) {
                            const Text("No Items LOADED");
                          } else if (snapshot.hasData) {
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data?.length ?? 0,
                                itemBuilder: ((context, index) {
                                  return Card(
                                    color: Colors.grey,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        Text(snapshot.data[index]["id"]
                                            .toString()),
                                        const SizedBox(width: 10),
                                        Text(snapshot.data[index]["name"]),
                                        const SizedBox(width: 10),
                                        Text('${snapshot.data[index]["category"]}' +
                                            ' ' +
                                            '${snapshot.data[index]["desc"]}'),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                            'Ksh ${snapshot.data[index]["price"]}',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 20),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final Bag cart = Bag(
                                                salesId: snapshot.data[index]
                                                    ["id"],
                                                serial: snapshot.data[index]
                                                    ["serial"],
                                                name: snapshot.data[index]
                                                    ["name"],
                                                category: snapshot.data[index]
                                                    ["category"],
                                                desc: snapshot.data[index]
                                                    ["desc"],
                                                qty: 1,
                                                price: snapshot.data[index]
                                                    ["price"],
                                                tax: snapshot.data[index]
                                                    ["tax"],
                                                profit: snapshot.data[index]
                                                        ["price"] -
                                                    snapshot.data[index]
                                                        ["cost"],
                                                image: '');

                                            final List<Map<String, dynamic>>
                                                indDetail =
                                                await sqlops.getIndDetail(
                                                    'cart',
                                                    snapshot.data[index]
                                                        ["name"]);
                                            print(indDetail);
                                            if (indDetail.isEmpty) {
                                              await sqlops.addToCart(
                                                  cart, 'cart');
                                              setState(
                                                () {
                                                  context
                                                      .read<PosChangeNotifier>()
                                                      .getCart();
                                                  _total = context
                                                      .read<PosChangeNotifier>()
                                                      .getPriceTotal();
                                                },
                                              );
                                              getCartItems().then((value) {
                                                setState(() {
                                                  cartItems = value;
                                                });
                                              });

                                              getTotal().then((value) {
                                                setState(() {
                                                  _totals = value;
                                                  _vats = value * 0.16;

                                                  //vat = value * 0.16;
                                                });
                                              });
                                            } else {
                                              showAlert(
                                                  "Item already exists in the cart");
                                            }
                                          },
                                          icon:
                                              const Icon(Icons.shopping_basket),
                                          label: const Text("sell"),
                                        )
                                      ]),
                                    ),
                                  );
                                }));
                          } else if (snapshot.hasError) {
                            return const Text("Data cannot be loaded");
                          }

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          );
                        }))
                  ],
                ),
              ),
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(children: [
                      ElevatedButton.icon(
                          onPressed: () async {
                            List<Bag> items = await getCartItems();
                            for (var item in items) {
                              final Bag cart = Bag(
                                salesId: item.salesId,
                                serial: item.serial,
                                name: item.name,
                                category: item.category,
                                desc: item.desc,
                                qty: item.qty,
                                price: item.price,
                                tax: item.tax,
                                profit: item.profit,
                                image: '',
                              );

                              await sqlops.addToSales(cart, 'sales');
                              await sqlops.subtractStock(
                                  item.salesId, item.qty);
                              await sqlops.deleteItem(item.salesId, "cart");
                            }

                            setState(() {
                              context.read<PosChangeNotifier>().getCart();
                              _total = context
                                  .read<PosChangeNotifier>()
                                  .getPriceTotal();
                            });

                            showAlert("Saved as sales successfully");
                          },
                          icon: const Icon(Icons.save),
                          label: const Text("Save")),
                      const SizedBox(
                        width: 40,
                      ),
                      ElevatedButton.icon(
                          onPressed: () {
                            printReceipt();
                          },
                          icon: const Icon(Icons.print_sharp),
                          label: const Text("Print"))
                    ]),
                    Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: Colors.black26),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Text("item",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                SizedBox(width: 60),
                                Text("price",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                SizedBox(width: 30),
                                Text("subtotal",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                SizedBox(width: 30),
                                Text("VAT",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                SizedBox(width: 30),
                                Text("Total",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                SizedBox(width: 30),
                                Text("Qty",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                SizedBox(width: 60),
                                Text("Remove",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange)),
                                SizedBox(width: 20)
                              ],
                            ),
                            Consumer<PosChangeNotifier>(
                                builder: (context, notifier, child) {
                              if (notifier.cart.isEmpty) {
                                const Text("No Items in the Cart");
                              } else {
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: notifier.cart.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                          child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Text(notifier.cart[index].name
                                                .toString()),
                                            const SizedBox(width: 20),
                                            Text(notifier.cart[index].price
                                                .toStringAsFixed(2)),
                                            const SizedBox(width: 20),
                                            Text(((notifier.cart[index].price) *
                                                    (notifier.cart[index].qty))
                                                .toStringAsFixed(2)),
                                            const SizedBox(width: 20),
                                            Text(((notifier.cart[index].price) *
                                                    (notifier.cart[index].qty) *
                                                    0.16)
                                                .toStringAsFixed(2)),
                                            const SizedBox(width: 10),
                                            Text(((notifier.cart[index].price *
                                                        notifier
                                                            .cart[index].qty *
                                                        0.16) +
                                                    (notifier
                                                            .cart[index].price *
                                                        notifier
                                                            .cart[index].qty))
                                                .toStringAsFixed(2)),
                                            const SizedBox(width: 10),
                                            IconButton(
                                                onPressed: () async {
                                                  await sqlops.updateQty(
                                                      notifier
                                                          .cart[index].salesId,
                                                      notifier.cart[index].qty +
                                                          1);
                                                  setState(() {
                                                    context
                                                        .read<
                                                            PosChangeNotifier>()
                                                        .getCart();

                                                    _total = context
                                                        .read<
                                                            PosChangeNotifier>()
                                                        .getPriceTotal();
                                                  });
                                                  getCartItems().then((value) {
                                                    setState(() {
                                                      cartItems = value;
                                                    });
                                                  });
                                                  getTotal().then((value) {
                                                    setState(() {
                                                      _totals = value;
                                                      _vats = value * 0.16;

                                                      //vat = value * 0.16;
                                                    });
                                                  });
                                                },
                                                icon: const Icon(Icons.add)),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Text(notifier.cart[index].qty
                                                .toString()),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            IconButton(
                                                onPressed: () async {
                                                  await sqlops.updateQty(
                                                      notifier
                                                          .cart[index].salesId,
                                                      notifier.cart[index].qty -
                                                          1);
                                                  setState(() {
                                                    context
                                                        .read<
                                                            PosChangeNotifier>()
                                                        .getCart();
                                                    _total = context
                                                        .read<
                                                            PosChangeNotifier>()
                                                        .getPriceTotal();
                                                  });
                                                  getCartItems().then((value) {
                                                    setState(() {
                                                      cartItems = value;
                                                    });
                                                  });

                                                  getTotal().then((value) {
                                                    setState(() {
                                                      _totals = value;
                                                      _vats = value * 0.16;

                                                      //vat = value * 0.16;
                                                    });
                                                  });
                                                },
                                                icon: const Icon(Icons.remove)),
                                            const SizedBox(width: 10),
                                            IconButton(
                                                onPressed: () async {
                                                  await sqlops.deleteItem(
                                                      notifier
                                                          .cart[index].salesId,
                                                      "cart");

                                                  setState(() {
                                                    context
                                                        .read<
                                                            PosChangeNotifier>()
                                                        .getCart();
                                                    _total = context
                                                        .read<
                                                            PosChangeNotifier>()
                                                        .getPriceTotal();
                                                  });

                                                  getTotal().then((value) {
                                                    setState(() {
                                                      _totals = value;
                                                      _vats = value * 0.16;

                                                      //vat = value * 0.16;
                                                    });
                                                  });

                                                  getCartItems().then((value) {
                                                    setState(() {
                                                      cartItems = value;
                                                    });
                                                  });
                                                },
                                                icon: const Icon(Icons.delete)),
                                          ],
                                        ),
                                      ));
                                    });
                              }

                              return const Text("no data");
                            }),
                            FutureBuilder(
                                future: _total,
                                builder: ((context, snapshot) {
                                  if (snapshot.data == null) {
                                    const Text("no data");
                                  } else if (snapshot.hasData) {
                                    return Column(children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Sub Total",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              )),
                                          Text("Ksh ${snapshot.data}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromARGB(
                                                    255, 158, 74, 74),
                                              ))
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("VAT ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              )),
                                          Text(
                                              "Ksh ${(snapshot.data * 0.16).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ))
                                        ],
                                      ),
                                      Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          height: 2,
                                          width: double.infinity,
                                          color: Colors.white24),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Total ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              )),
                                          Text(
                                              "Ksh ${(snapshot.data * 0.16 + snapshot.data).toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ))
                                        ],
                                      )
                                    ]);
                                  } else if (snapshot.hasError) {
                                    return const Text("no data");
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                  );
                                }))
                          ],
                        ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> printReceipt() async {
    final doc = pw.Document(compress: true);
    final font = await PdfGoogleFonts.nunitoExtraLight();
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw
            .Column(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
          pw.Center(
              child: pw.Text("Touch & Light", style: pw.TextStyle(font: font))),
          pw.SizedBox(height: 40),
          pw.Text("==============", style: pw.TextStyle(font: font)),
          pw.Row(children: [
            pw.Text("Name", style: pw.TextStyle(font: font)),
            pw.SizedBox(width: 20),
            pw.Text("Qty", style: pw.TextStyle(font: font)),
            pw.SizedBox(width: 20),
            pw.Text("Price", style: pw.TextStyle(font: font)),
            pw.SizedBox(width: 20),
            pw.Text("Sub Total", style: pw.TextStyle(font: font)),
            pw.SizedBox(width: 20),
            pw.Text("VAT", style: pw.TextStyle(font: font)),
            pw.SizedBox(width: 20),
            pw.Text("Total", style: pw.TextStyle(font: font)),
            pw.SizedBox(width: 20),
          ]),
          pw.ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              return pw.Column(children: [
                pw.Row(children: [
                  pw.Text(cartItems[index].name,
                      style: pw.TextStyle(font: font)),
                  pw.SizedBox(width: 20),
                  pw.Text(cartItems[index].qty.toString(),
                      style: pw.TextStyle(font: font)),
                  pw.SizedBox(width: 20),
                  pw.Text(cartItems[index].price.toString(),
                      style: pw.TextStyle(font: font)),
                  pw.SizedBox(width: 20),
                  pw.Text(
                      (cartItems[index].price * cartItems[index].qty)
                          .toString(),
                      style: pw.TextStyle(font: font)),
                  pw.SizedBox(width: 20),
                  pw.Text(
                      (cartItems[index].price * cartItems[index].qty * 0.16)
                          .toString(),
                      style: pw.TextStyle(font: font)),
                  pw.SizedBox(width: 20),
                  pw.Text(
                      ((cartItems[index].price * cartItems[index].qty * 0.16) +
                              (cartItems[index].price * cartItems[index].qty))
                          .toString(),
                      style: pw.TextStyle(font: font))
                ]),
              ]);
            },
          ),
          pw.SizedBox(height: 40),
          pw.Text("====", style: pw.TextStyle(font: font)),
          pw.Row(children: [
            pw.Text("Sub Total: ", style: pw.TextStyle(font: font)),
            pw.Text(_totals.toString(), style: pw.TextStyle(font: font))
          ]),
          pw.Row(children: [
            pw.Text("VAT(16%): ", style: pw.TextStyle(font: font)),
            pw.Text(_vats.toString(), style: pw.TextStyle(font: font))
          ]),
          pw.Row(children: [
            pw.Text("Total: ",
                style:
                    pw.TextStyle(font: font, fontWeight: pw.FontWeight.bold)),
            pw.Text((_vats + _totals).toString(),
                style: pw.TextStyle(font: font))
          ])
        ]);
      },
    ));
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}
