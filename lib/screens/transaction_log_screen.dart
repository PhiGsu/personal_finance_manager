import 'package:flutter/material.dart';
import 'package:personal_finance_manager/database.dart';
import 'package:personal_finance_manager/main.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';

class TransactionLogScreen extends StatefulWidget {
  const TransactionLogScreen({super.key});

  @override
  State<TransactionLogScreen> createState() => _TransactionLogScreenState();
}

class _TransactionLogScreenState extends State<TransactionLogScreen> {
  Map<int, String> categories = {};
  List<UserTransaction> transactions = [];

  final TextEditingController costController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Make concurrent calls
    final results = await Future.wait([DatabaseHelper.instance.getCategories(), DatabaseHelper.instance.getTransactions()]);

    setState(() {
      categories = results[0] as Map<int, String>;
      transactions = results[1] as List<UserTransaction>;
    });
  }

  Future<void> _saveTransaction(UserTransaction transaction) async {
    await DatabaseHelper.instance.insert('Transaction', transaction.toMap());

    setState(() async {
      transactions = await DatabaseHelper.instance.getTransactions();
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
                    padding: const EdgeInsets.all(8.0),
                    child: const Text('Transaction Log',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TransactionForm(
                        onSave: _saveTransaction, categories: categories)),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TransactionTable(
                      transactions: transactions, categories: categories),
                )
              ],
            )));
  }
}

// Used to create and save a transaction to the database
class TransactionForm extends StatefulWidget {
  final Map<int, String> categories;
  final Function(UserTransaction) onSave;

  const TransactionForm({
    super.key,
    required this.onSave,
    required this.categories,
  });

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final TextEditingController costController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime date = DateTime.now();
  int selectedCategory = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5), border: Border.all()),
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(spacing: 8, children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: costController,
                      decoration: const InputDecoration(
                        labelText: 'Cost',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      maxLength: 100,
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              Row(children: [
                Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Text(date.toIso8601String().split('T')[0]),
                        IconButton(
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null && pickedDate != date) {
                              setState(() {
                                date = pickedDate;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month_outlined),
                        ),
                      ]),
                    )),
                SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey)),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    child: DropdownButton<int>(
                      value: selectedCategory,
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                      items: widget.categories.entries
                          .map((entry) => DropdownMenuItem<int>(
                                value: entry.key,
                                child: Text(entry.value),
                              ))
                          .toList(),
                    ),
                  ),
                ),
                Expanded(child: Container()),
                IconButton(
                    onPressed: () {
                      final newTransaction = UserTransaction(
                          date: date,
                          cost: double.parse(costController.text),
                          description: descriptionController.text,
                          categoryId: selectedCategory);
                      widget.onSave(newTransaction);
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Color(0xFFDAE8FC)),
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ))),
                    icon: const Icon(Icons.add)),
              ])
            ])));
  }
}

// Displays the user's transactions
class TransactionTable extends StatelessWidget {
  final List<UserTransaction> transactions;
  final Map<int, String> categories;

  const TransactionTable(
      {super.key, required this.transactions, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5), border: Border.all()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide()),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5), topRight: Radius.circular(5)),
                color: Theme.of(context).colorScheme.inversePrimary),
            child: Padding(
                padding: const EdgeInsets.all(8),
                child: const Text('Transactions',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const <DataColumn>[
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Cost')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Category')),
              ],
              rows: transactions.map((transaction) {
                return DataRow(cells: <DataCell>[
                  // maybe set onLongPress to edit a transaction
                  DataCell(
                      Text(transaction.date.toIso8601String().split('T')[0])),
                  DataCell(Text(transaction.cost.toStringAsFixed(2))),
                  DataCell(Text(transaction.description)),
                  DataCell(
                      Text(categories[transaction.categoryId] ?? 'Unknown')),
                ]);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }
}
