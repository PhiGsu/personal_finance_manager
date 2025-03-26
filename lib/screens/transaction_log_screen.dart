import 'package:flutter/material.dart';
import 'package:personal_finance_manager/database.dart';
import 'package:personal_finance_manager/main.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';
import 'package:personal_finance_manager/widgets/transaction_form.dart';
import 'package:personal_finance_manager/widgets/transaction_table.dart';

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
    await DatabaseHelper.instance
        .insert('UserTransaction', transaction.toMap());
    final updatedTransactions = await DatabaseHelper.instance.getTransactions();

    setState(() {
      transactions = updatedTransactions;
    });
  }

  Future<void> _showEditDialog(UserTransaction transaction) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Transaction'),
          content: SingleChildScrollView(
            child: TransactionForm(
              categories: categories,
              onSave: (updatedTransaction) async {
                await DatabaseHelper.instance
                    .update('UserTransaction', updatedTransaction.toMap());
                _loadData();
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              onDelete: _showDeleteDialog,
              editTransaction: transaction,
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(UserTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content:
              const Text('Are you sure you want to delete this transaction?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance
                    .delete('UserTransaction', transaction.id!);
                _loadData();
                if (context.mounted) {
                  // Closes the confirm and edit dialogs
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
                onEdit: _showEditDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
