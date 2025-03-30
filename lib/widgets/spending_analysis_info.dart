import 'package:flutter/material.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';

class SpendingAnalysisInfo extends StatelessWidget {
  final List<UserTransaction> transactions;
  final Map<int, String> categories;
  final String timePeriod;

  const SpendingAnalysisInfo({
    super.key,
    required this.transactions,
    required this.categories,
    required this.timePeriod,
  });

  double _calculateTotalSpent() {
    return transactions
        .where((transaction) => transaction.amount < 0)
        .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
  }

  double _calculateTotalGained() {
    return transactions
        .where((transaction) => transaction.amount > 0)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double _calculatePeriodChanges(DateTime start, DateTime end,
      {required bool forIncome}) {
    final transactionsInPeriod = transactions
        .where((transaction) =>
            transaction.date.isAfter(start) && transaction.date.isBefore(end))
        .toList();

    return transactionsInPeriod
        .where((transaction) =>
            forIncome ? transaction.amount > 0 : transaction.amount < 0)
        .fold(0.0, (sum, transaction) => sum + transaction.amount.abs());
  }

  double _calculateWeekChanges({required bool forIncome}) {
    final DateTime today = DateTime.now();
    final DateTime startOfWeek = today.subtract(const Duration(days: 7));
    return _calculatePeriodChanges(startOfWeek, today, forIncome: forIncome);
  }

  double _calculateMonthChanges({required bool forIncome}) {
    final DateTime today = DateTime.now();
    final DateTime startOfMonth =
        DateTime(today.year, today.month - 1, today.day);
    return _calculatePeriodChanges(startOfMonth, today, forIncome: forIncome);
  }

  double _calculateYearChanges({required bool forIncome}) {
    final DateTime today = DateTime.now();
    final DateTime startOfYear =
        DateTime(today.year - 1, today.month, today.day);
    return _calculatePeriodChanges(startOfYear, today, forIncome: forIncome);
  }

  double _calculateAverageSpending() {
    final spendingTransactions =
        transactions.where((transaction) => transaction.amount < 0).toList();
    if (spendingTransactions.isEmpty) return 0.0;
    return _calculateTotalSpent() / spendingTransactions.length;
  }

  double _calculateAverageIncome() {
    final incomeTransactions =
        transactions.where((transaction) => transaction.amount > 0).toList();
    if (incomeTransactions.isEmpty) return 0.0;
    return _calculateTotalGained() / incomeTransactions.length;
  }

  UserTransaction? _findLowestSpending() {
    final spendingTransactions =
        transactions.where((transaction) => transaction.amount < 0).toList();
    if (spendingTransactions.isEmpty) return null;
    return spendingTransactions
        .reduce((curr, next) => curr.amount > next.amount ? curr : next);
  }

  UserTransaction? _findLowestGain() {
    final incomeTransactions =
        transactions.where((transaction) => transaction.amount > 0).toList();
    if (incomeTransactions.isEmpty) return null;
    return incomeTransactions
        .reduce((curr, next) => curr.amount < next.amount ? curr : next);
  }

  UserTransaction? _findLargestSpending() {
    final spendingTransactions =
        transactions.where((transaction) => transaction.amount < 0).toList();
    if (spendingTransactions.isEmpty) return null;
    return spendingTransactions
        .reduce((curr, next) => curr.amount < next.amount ? curr : next);
  }

  UserTransaction? _findLargestGain() {
    final incomeTransactions =
        transactions.where((transaction) => transaction.amount > 0).toList();
    if (incomeTransactions.isEmpty) return null;
    return incomeTransactions
        .reduce((curr, next) => curr.amount > next.amount ? curr : next);
  }

  String _formatAmount(double amount) {
    return amount < 0
        ? '-\$${amount.abs().toStringAsFixed(2)}'
        : '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final lowestSpending = _findLowestSpending();
    final lowestGain = _findLowestGain();
    final largestSpending = _findLargestSpending();
    final largestGain = _findLargestGain();
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.85,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1.1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Total Spent: \$${_calculateTotalSpent().toStringAsFixed(2)}'),
            Text(
                'Total Gained: \$${_calculateTotalGained().toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            Text('Week Changes:'),
            Text(
                ' - Income Change: ${_formatAmount(_calculateWeekChanges(forIncome: true))}'),
            Text(
                ' - Spending Change: ${_formatAmount(_calculateWeekChanges(forIncome: false))}'),
            if (timePeriod != 'Week') ...[
              const SizedBox(height: 16),
              Text('Month Changes:'),
              Text(
                  ' - Income Change: ${_formatAmount(_calculateMonthChanges(forIncome: true))}'),
              Text(
                  ' - Spending Change: ${_formatAmount(_calculateMonthChanges(forIncome: false))}'),
            ],
            if (timePeriod == 'Year') ...[
              const SizedBox(height: 16),
              Text('Year Changes:'),
              Text(
                  ' - Income Change: ${_formatAmount(_calculateYearChanges(forIncome: true))}'),
              Text(
                  ' - Spending Change: ${_formatAmount(_calculateYearChanges(forIncome: false))}'),
            ],
            const SizedBox(height: 16),
            Text(
                'Average Spending: \$${_calculateAverageSpending().toStringAsFixed(2)}'),
            Text(
                'Average Income: \$${_calculateAverageIncome().toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            Text(
                'Largest Spending: ${largestSpending != null ? _formatAmount(largestSpending.amount) : 'N/A'}'),
            Text(
                'Lowest Spending: ${lowestSpending != null ? _formatAmount(lowestSpending.amount) : 'N/A'}'),
            Text(
                'Largest Gain: ${largestGain != null ? _formatAmount(largestGain.amount) : 'N/A'}'),
            Text(
                'Lowest Gain: ${lowestGain != null ? _formatAmount(lowestGain.amount) : 'N/A'}'),
            const SizedBox(height: 16),
            Text('Number of Transactions: ${transactions.length}'),
          ],
        ),
      ),
    );
  }
}
