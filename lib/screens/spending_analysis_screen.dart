import 'package:flutter/material.dart';
import 'package:personal_finance_manager/database.dart';
import 'package:personal_finance_manager/main.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';
import 'package:personal_finance_manager/widgets/category_bar_graph.dart';
import 'package:personal_finance_manager/widgets/spending_analysis_info.dart';
import 'package:personal_finance_manager/widgets/spending_graph.dart';

class SpendingAnalysisScreen extends StatefulWidget {
  const SpendingAnalysisScreen({super.key});

  @override
  State<SpendingAnalysisScreen> createState() => _SpendingAnalysisScreenState();
}

class _SpendingAnalysisScreenState extends State<SpendingAnalysisScreen> {
  Map<int, String> categories = {};
  List<UserTransaction> transactions = [];
  double balance = 0;
  String selectedTimePeriod = 'Week';

  final timePeriods = ["Week", "Month", "Year"];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final results = await Future.wait([
      DatabaseHelper.instance.getCategories(),
      DatabaseHelper.instance.getBalance(),
    ]);

    setState(() {
      categories = results[0] as Map<int, String>;
      balance = results[1] as double;
    });
    _loadTransactions(selectedTimePeriod);
  }

  void _loadTransactions(String timePeriod) async {
    DateTime startDate;
    switch (timePeriod) {
      case 'Week':
        startDate = DateTime.now().subtract(Duration(days: 7));
        break;
      case 'Month':
        startDate = DateTime.now().subtract(Duration(days: 30));
        break;
      case 'Year':
        startDate = DateTime.now().subtract(Duration(days: 365));
        break;
      default:
        startDate = DateTime.now().subtract(Duration(days: 7));
    }

    final filteredTransactions =
        await DatabaseHelper.instance.getTransactionsAfterDate(startDate);

    setState(() {
      transactions = filteredTransactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinanceMangerAppBar(),
      drawer: const FinanceMangerAppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 3,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Color(0xFF144664)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: const Text(
                  'Spending Analysis',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DropdownButton<String>(
                    value: selectedTimePeriod,
                    onChanged: (timePeriod) {
                      setState(() {
                        selectedTimePeriod = timePeriod!;
                      });
                      _loadTransactions(timePeriod!);
                    },
                    items: timePeriods
                        .map((timePeriod) => DropdownMenuItem<String>(
                              value: timePeriod,
                              child: Text(timePeriod),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Balance:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                spacing: 10,
                children: [
                  Text(
                    'Balance Overview',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SpendingGraph(
                    transactions: transactions,
                    balance: balance,
                    timePeriod: selectedTimePeriod,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                spacing: 10,
                children: [
                  Text(
                    'Spending by Category',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CategoryBarGraph(
                    categories: categories,
                    transactions: transactions,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: SpendingAnalysisInfo(
                transactions: transactions,
                categories: categories,
                timePeriod: selectedTimePeriod,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
