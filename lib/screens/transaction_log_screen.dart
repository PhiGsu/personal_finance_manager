import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    // Make concurrent calls
    final results = await Future.wait([
      DatabaseHelper.instance.getCategories(),
      DatabaseHelper.instance.getTransactions(),
    ]);

    setState(() {
      categories = results[0] as Map<int, String>;
      transactions = results[1] as List<UserTransaction>;
    });
  }

  Future<void> _saveTransaction(UserTransaction transaction) async {
    await DatabaseHelper.instance.insert('Transaction', transaction.toMap());
    final updatedTransactions = await DatabaseHelper.instance.getTransactions();

    setState(() {
      transactions = updatedTransactions;
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
                child: const Text(
                  'Transaction Log',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TransactionForm(
                onSave: _saveTransaction,
                categories: categories,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TransactionTable(
                transactions: transactions,
                categories: categories,
              ),
            )
          ],
        ),
      ),
    );
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
  late final TextEditingController costController;
  late final TextEditingController descriptionController;
  DateTime date = DateTime.now();
  int? selectedCategory;

  @override
  void initState() {
    super.initState();
    costController = TextEditingController();
    descriptionController = TextEditingController();
    costController.addListener(_onTextChanged);
    descriptionController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    costController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void resetForm() {
    costController.clear();
    descriptionController.clear();
    setState(() {
      date = DateTime.now();
      selectedCategory = null;
    });
  }

  void _onTextChanged() {
    setState(() {});
  }

  bool _areFieldsValid() {
    return costController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedCategory != null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(),
      ),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
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
                    keyboardType: TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^-?[0-9]*(\.[0-9]{0,2})?$'),
                      ),
                    ],
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
            Wrap(alignment: WrapAlignment.start, runSpacing: 8, children: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey),
                    ),
                    constraints: const BoxConstraints(maxWidth: 200),
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
              ),
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.grey),
                ),
                constraints: const BoxConstraints(maxWidth: 200),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  child: DropdownButton<int>(
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    borderRadius: BorderRadius.circular(5),
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
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _areFieldsValid()
                      ? () {
                          final newTransaction = UserTransaction(
                            date: date,
                            cost: double.parse(costController.text),
                            description: descriptionController.text,
                            categoryId: selectedCategory!,
                          );
                          widget.onSave(newTransaction);
                          resetForm();
                        }
                      : null,
                  style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                        _areFieldsValid()
                            ? Color(0xFFDAE8FC)
                            : const Color.fromARGB(255, 204, 204, 204),
                      ),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ))),
                  icon: const Icon(Icons.add),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border(bottom: BorderSide()),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              color: Theme.of(context).colorScheme.inversePrimary),
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: const Text('Transactions',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            constraints:
                BoxConstraints(minWidth: MediaQuery.of(context).size.width),
            child: DataTable(
              dataRowMaxHeight: double.infinity,
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
                    Text(transaction.date.toIso8601String().split('T')[0]),
                  ),
                  DataCell(
                    Text(
                      transaction.cost < 0
                          ? '-\$${transaction.cost.abs().toStringAsFixed(2)}'
                          : '\$${transaction.cost.toStringAsFixed(2)}',
                    ),
                  ),
                  DataCell(
                    Container(
                      constraints: const BoxConstraints(maxWidth: 100),
                      child: Text(transaction.description),
                    ),
                  ),
                  DataCell(
                      Text(categories[transaction.categoryId] ?? 'Unknown')),
                ]);
              }).toList(),
            ),
          ),
        ),
      ]),
    );
  }
}
