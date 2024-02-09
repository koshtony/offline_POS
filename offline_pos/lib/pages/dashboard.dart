import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offline_pos/database/models.dart';
import 'package:offline_pos/database/operations.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat dateMonthFormat = DateFormat("MM");

  Future getQtyTotal() async {
    String date1 = dateFormat.format(DateTime.now());
    String date2 = dateFormat.format(DateTime.now());

    return await SQLOps.getTotals("qty", date1, date2);
  }

  Future getMonthTotal() async {
    String date1 = dateMonthFormat.format(DateTime.now());

    return await SQLOps.getMonthTotals("qty", date1);
  }

  Future getMonthRev() async {
    String date1 = dateMonthFormat.format(DateTime.now());

    return await SQLOps.getMonthTotals("price", date1);
  }

  Future getMonthProfit() async {
    String date1 = dateMonthFormat.format(DateTime.now());

    return await SQLOps.getMonthTotals("profit", date1);
  }

  Future getSalesList() async {
    return await SQLOps.getDetails('sales');
  }

  Future getStocksCat() async {
    return await SQLOps.groupByCat();
  }

  Future getIndSales(String query) async {
    return await SQLOps.getIndDetail("sales", query);
  }

  Future stocksTotal() async {
    return SQLOps.getStocksQtyTotal();
  }

  Future stocksCost() async {
    return SQLOps.getStocksValTotal("cost");
  }

  Future<dynamic>? _sales;
  late double _qtyTotal = 0.0;
  late double _qtyMonthTotal = 0.0;
  late double _monthRev = 0.0;
  late double _monthProfit = 0.0;
  late List<Map> _stocksCat = [];
  late double _totalStocks = 0.0;
  late double _totalCost = 0.0;

  TextEditingController searchTabController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _sales = getSalesList();

    getQtyTotal().then((value) {
      setState(() {
        _qtyTotal = value;
      });
    });

    getMonthTotal().then((value) {
      setState(() {
        _qtyMonthTotal = value;
      });
    });

    getMonthRev().then((value) {
      setState(() {
        _monthRev = value;
      });
    });

    getMonthProfit().then((value) {
      setState(() {
        _monthProfit = value;
      });
    });

    getStocksCat().then((value) {
      setState(() {
        _stocksCat = value;
      });
    });

    stocksTotal().then((value) {
      setState(() {
        _totalStocks = value;
      });
    });

    stocksCost().then((value) {
      setState(() {
        _totalCost = value;
      });
    });
  }

  void filterTable(String query) {
    setState(() {
      _sales = getIndSales(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<DashList> info = [
      DashList(
          title: "Today sales/Target",
          value: _qtyTotal,
          percentage: _qtyTotal / _totalStocks,
          icon: const Icon(Icons.calendar_view_day),
          color: Colors.green),
      DashList(
          title: "Monthly sales/Target",
          value: _qtyMonthTotal,
          percentage: _qtyMonthTotal / _totalStocks,
          icon: const Icon(Icons.calendar_view_month),
          color: Colors.blue),
      DashList(
          title: "Monthly Revenue/Target",
          value: _monthRev,
          percentage: _monthRev / _totalCost,
          icon: const Icon(Icons.payments),
          color: Colors.yellow),
      DashList(
          title: "Monthly Profit/Target",
          value: _monthProfit,
          percentage: 0.6,
          icon: const Icon(Icons.money),
          color: Colors.orange)
    ];
    return Scaffold(
        backgroundColor: const Color(0xFF2A2D3E),
        body: SafeArea(
            child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: Row(
              children: [
                Flexible(
                    flex: 5,
                    child: Column(
                      children: [
                        Row(children: []),
                        const SizedBox(height: 16),
                        GridView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: info.length,
                            shrinkWrap: true,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8,
                            ),
                            itemBuilder: ((context, index) => Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: Color(0xFF212332),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 40,
                                                width: 40,
                                                decoration: BoxDecoration(
                                                  color: info[index].color,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(20)),
                                                ),
                                                child: info[index].icon),
                                          ]),
                                      Text(info[index].title,
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          )),
                                      const SizedBox(height: 20),
                                      Stack(children: [
                                        Container(
                                          width: double.infinity,
                                          height: 5,
                                          decoration: BoxDecoration(
                                              color: info[index]
                                                  .color
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(16))),
                                        ),
                                        LayoutBuilder(
                                            builder: (context, constraints) =>
                                                Container(
                                                  width: constraints.maxWidth *
                                                          info[index]
                                                              .percentage ??
                                                      0.0,
                                                  height: 5,
                                                  decoration: BoxDecoration(
                                                      color: info[index].color,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  16))),
                                                ))
                                      ]),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(info[index].value.toString(),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ))
                                        ],
                                      )
                                    ],
                                  ),
                                ))),
                        const SizedBox(height: 20),
                        Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                                color: Color(0xFF212332),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Column(children: [
                              Text("Monthly sales",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  )),
                              TextField(
                                  controller: searchTabController,
                                  style: TextStyle(color: Colors.orange),
                                  onChanged: (value) {
                                    if (value == "") {
                                      _sales = getSalesList();
                                    } else {
                                      filterTable(value);
                                    }
                                  },
                                  decoration: InputDecoration(
                                      labelText: "search",
                                      prefixIcon: Icon(Icons.search))),
                              FutureBuilder(
                                  future: _sales,
                                  builder: ((context, snapshot) {
                                    if (snapshot.data == null) {
                                      const Text("No sales recorded");
                                    } else if (snapshot.hasData) {
                                      return SizedBox(
                                        width: double.infinity,
                                        child: DataTable(
                                            columns: [
                                              DataColumn(
                                                  label: Text("id",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))),
                                              DataColumn(
                                                  label: Text("name",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))),
                                              DataColumn(
                                                  label: Text("category",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))),
                                              DataColumn(
                                                  label: Text("price",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))),
                                              DataColumn(
                                                  label: Text("profit",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))),
                                              DataColumn(
                                                  label: Text("Date",
                                                      style: TextStyle(
                                                          color: Colors.white)))
                                            ],
                                            rows: snapshot.data
                                                .map<DataRow>(
                                                    (sale) => DataRow(cells: [
                                                          DataCell(Text(
                                                              sale["salesId"]
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                          DataCell(Text(
                                                              sale["name"],
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                          DataCell(Text(
                                                              sale["category"]
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                          DataCell(Text(
                                                              sale["price"]
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                          DataCell(Text(
                                                              sale["profit"]
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white))),
                                                          DataCell(Text(
                                                              sale["salesDate"]
                                                                  .toString(),
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white)))
                                                        ]))
                                                .toList()),
                                      );
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
                            ]))
                      ],
                    )),
                const SizedBox(
                  width: 40,
                ),
                Flexible(
                    flex: 2,
                    child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration:
                            const BoxDecoration(color: Color(0xFF212332)),
                        child: Column(children: [
                          const Text(
                            "Stocks/sales Ratio ",
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          SizedBox(
                              height: 200,
                              child: Stack(children: [
                                PieChart(PieChartData(sections: [
                                  PieChartSectionData(
                                    color: Colors.blue,
                                    value: 20,
                                    title: "sales",
                                    showTitle: true,
                                    radius: 15,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange,
                                    value: 80,
                                    title: "stocks",
                                    showTitle: true,
                                    radius: 25,
                                  ),
                                ])),
                                Positioned.fill(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Text(
                                        "${80 / 20}%",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      Text("stocks/sales",
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.white,
                                          ))
                                    ]))
                              ])),
                          const SizedBox(height: 20),
                          Flexible(
                              child: ListView.builder(
                                  itemCount: _stocksCat.length,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      color: Colors.orange,
                                      child: ListTile(
                                        leading: const Icon(Icons.category),
                                        title: Text(_stocksCat[index]
                                                ["category"]
                                            .toString()),
                                        trailing: Text(_stocksCat[index]
                                                ["sumQty"]
                                            .toString()),
                                        selected: true,
                                      ),
                                    );
                                  }))
                        ])))
              ],
            ),
          ),
        )));
  }
}
