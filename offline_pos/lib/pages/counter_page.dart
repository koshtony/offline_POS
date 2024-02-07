import 'package:flutter/material.dart';
import 'package:flutter_shopping_cart/flutter_shopping_cart.dart';
import 'package:offline_pos/database/models.dart';
import 'package:offline_pos/database/operations.dart';
import 'package:offline_pos/state_management/pos_change_notifier.dart';
import 'package:provider/provider.dart';

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  Future getStocks() async {
    return await SQLOps.getDetails('stocks');
  }

  Future getIndStocks(id) async {
    return await SQLOps.getIndDetail("stocks", id);
  }

  Future getTotal() async {
    return await SQLOps.getSum();
  }

  Future<List<Bag>> getCartItems() async {
    return await SQLOps.getBagList();
  }

  Future getVat() async {
    return await SQLOps.getSum() * 0.16;
  }

  Future<dynamic>? _stocksList;

  Future<dynamic>? _total;

  Future<dynamic>? _vat;

  var shoppingCart = ShoppingCart();

  @override
  void initState() {
    super.initState();
    _stocksList = getStocks();
    context.read<PosChangeNotifier>().getCart();
    _total = getTotal();
    _vat = getVat();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<PosChangeNotifier>(context);
    return Row(
      children: [
        Flexible(
          child: FractionallySizedBox(
              widthFactor: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Items List",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
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
                                      const SizedBox(width: 40),
                                      Text(snapshot.data[index]["name"]),
                                      const SizedBox(width: 40),
                                      Text('${snapshot.data[index]["category"]}' +
                                          ' ' +
                                          '${snapshot.data[index]["desc"]}'),
                                      const SizedBox(
                                        width: 40,
                                      ),
                                      Text(
                                          'Ksh ${snapshot.data[index]["price"]}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 80),
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
                                              tax: snapshot.data[index]["tax"],
                                              profit: snapshot.data[index]
                                                      ["price"] -
                                                  snapshot.data[index]["cost"],
                                              image: '');
                                          print(cart);
                                          final List<Map<String, dynamic>>
                                              indDetail =
                                              await SQLOps.getIndDetail('cart',
                                                  snapshot.data[index]["name"]);
                                          print(indDetail);
                                          if (indDetail.isEmpty) {
                                            await SQLOps.addToCart(
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
                                          } else {
                                            print("item alread exists");
                                          }
                                        },
                                        icon: const Icon(Icons.shopping_basket),
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
              )),
        ),
        Flexible(
          child: FractionallySizedBox(
              widthFactor: 1,
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

                            await SQLOps.addToSales(cart, 'sales');
                            print("done");
                          }
                        },
                        icon: const Icon(Icons.save),
                        label: const Text("Save")),
                    const SizedBox(
                      width: 40,
                    ),
                    ElevatedButton.icon(
                        onPressed: () {},
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
                                          Text(notifier.cart[index].salesId
                                              .toString()),
                                          Text(notifier.cart[index].name
                                              .toString()),
                                          const SizedBox(width: 40),
                                          Text(
                                              'Ksh ${notifier.cart[index].price.toString()}'),
                                          const SizedBox(width: 40),
                                          IconButton(
                                              onPressed: () async {
                                                print(notifier
                                                    .cart[index].salesId);
                                                await SQLOps.updateQty(
                                                    notifier
                                                        .cart[index].salesId,
                                                    notifier.cart[index].qty +
                                                        1);
                                                setState(() {
                                                  context
                                                      .read<PosChangeNotifier>()
                                                      .getCart();

                                                  _total = context
                                                      .read<PosChangeNotifier>()
                                                      .getPriceTotal();
                                                });
                                                print(_total);
                                              },
                                              icon: const Icon(Icons.add)),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Text(notifier.cart[index].qty
                                              .toString()),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          IconButton(
                                              onPressed: () async {
                                                await SQLOps.updateQty(
                                                    notifier
                                                        .cart[index].salesId,
                                                    notifier.cart[index].qty -
                                                        1);
                                                setState(() {
                                                  context
                                                      .read<PosChangeNotifier>()
                                                      .getCart();
                                                  _total = context
                                                      .read<PosChangeNotifier>()
                                                      .getPriceTotal();
                                                });
                                              },
                                              icon: const Icon(Icons.remove)),
                                          const SizedBox(width: 40),
                                          IconButton(
                                              onPressed: () async {
                                                await SQLOps.deleteItem(
                                                    notifier
                                                        .cart[index].salesId,
                                                    "cart");

                                                setState(() {
                                                  context
                                                      .read<PosChangeNotifier>()
                                                      .getCart();
                                                  _total = context
                                                      .read<PosChangeNotifier>()
                                                      .getPriceTotal();
                                                });
                                                print("done");
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
                                        Text("Ksh ${snapshot.data * 0.16}",
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
                                            "Ksh ${snapshot.data * 0.16 + snapshot.data}",
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
              )),
        )
      ],
    );
  }
}
