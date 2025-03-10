import 'package:flutter/material.dart';
import 'package:personal_finance_manager/main.dart';

class SpendingAnalysisScreen extends StatelessWidget {
  const SpendingAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinanceMangerAppBar(),
      drawer: const FinanceMangerAppDrawer(),
      body: Center(
        child: const Text('Welcome to Spending Analysis Screen!'),
      ),
    );
  }
}