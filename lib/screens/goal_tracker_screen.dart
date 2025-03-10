import 'package:flutter/material.dart';
import 'package:personal_finance_manager/main.dart';

class GoalTrackerScreen extends StatelessWidget {
  const GoalTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinanceMangerAppBar(),
      drawer: const FinanceMangerAppDrawer(),
      body: Center(
        child: const Text('Welcome to Goal Tracker Screen!'),
      ),
    );
  }
}