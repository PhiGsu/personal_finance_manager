import 'package:flutter/material.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';

// Displays the user's transactions
class TransactionTable extends StatelessWidget {
  final List<UserTransaction> transactions;
  final Map<int, String> categories;
  final Function(UserTransaction) onEdit;

  const TransactionTable(
      {super.key,
      required this.transactions,
      required this.categories,
      required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(),
        color: Colors.white,
      ),
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
              columnSpacing: 20,
              columns: const <DataColumn>[
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Cost')),
                DataColumn(label: Text('Description')),
                DataColumn(label: Text('Category')),
              ],
              rows: transactions.map((transaction) {
                return DataRow(
                    onLongPress: () => onEdit(transaction),
                    cells: <DataCell>[
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
                      DataCell(Text(
                          categories[transaction.categoryId] ?? 'Unknown')),
                    ]);
              }).toList(),
            ),
          ),
        ),
      ]),
    );
  }
}