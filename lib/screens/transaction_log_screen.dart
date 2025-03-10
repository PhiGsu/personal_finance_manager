import 'package:flutter/material.dart';
import 'package:personal_finance_manager/main.dart';

class TransactionLogScreen extends StatefulWidget {
  const TransactionLogScreen({super.key});

  @override
  State<TransactionLogScreen> createState() => _TransactionLogScreenState();
}

class _TransactionLogScreenState extends State<TransactionLogScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinanceMangerAppBar(),
      drawer: const FinanceMangerAppDrawer(),
      body: Center(
        child: const Text('Welcome to Transaction log Screen!'),
      ),
    );
  }
}