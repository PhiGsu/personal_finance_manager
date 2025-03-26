import 'package:flutter/material.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';

// Displays analysis on the user's spending habits
class SpendingAnalysisInfo extends StatelessWidget {
  final List<UserTransaction> transactions;
  final Map<int, String> categories;

  const SpendingAnalysisInfo({
    super.key,
    required this.transactions,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    throw UnimplementedError();
  }

  // total spent
  // total gained

  // show week changes always
  // show month change if timePeriod != week
  // show year change if timePeriod == year

  // Avg spending
  // Avg income

  // Largest spending
  // Lowest spending
  // Largest gain
  // Lowest gain

  // number of transactions
  // show spending by categories
}