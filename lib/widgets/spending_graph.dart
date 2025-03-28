import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';

// Displays graph of user's spending and income
class SpendingGraph extends StatelessWidget {
  final List<UserTransaction> transactions;
  final double balance;
  final String timePeriod;

  static const List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  static const List<String> daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  const SpendingGraph(
      {super.key,
      required this.transactions,
      required this.timePeriod,
      required this.balance});

  // Group transactions by date and sum their amounts
  List<FlSpot> _prepareData() {
    Map<DateTime, double> dateAmountMap = _initializeDateMap();

    for (var transaction in transactions) {
      DateTime dateKey = _getDateGroup(transaction.date);
      if (dateAmountMap.containsKey(dateKey)) {
        dateAmountMap[dateKey] = dateAmountMap[dateKey]! + transaction.amount;
      }
    }

    // Map entries sorted by date descending
    List<MapEntry<DateTime, double>> sortedEntries =
        dateAmountMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key));

    double calculatedBalance = balance;

    return sortedEntries.map((entry) {
      FlSpot flSpot = FlSpot(
          sortedEntries.length - sortedEntries.indexOf(entry) - 1,
          calculatedBalance);
      calculatedBalance -= entry.value;
      return flSpot;
    }).toList();
  }

  Map<DateTime, double> _initializeDateMap() {
    Map<DateTime, double> dateAmountMap = {};
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    switch (timePeriod) {
      case 'Week':
        for (int i = 0; i < 7; i++) {
          dateAmountMap[today.subtract(Duration(days: i))] = 0.0;
        }
        break;

      case 'Month':
        for (int i = 0; i < 30; i++) {
          dateAmountMap[today.subtract(Duration(days: i))] = 0.0;
        }
        break;

      case 'Year':
        for (int i = 0; i < 12; i++) {
          DateTime month = DateTime(today.year, today.month - i);
          if (month.month <= 0) {
            month = DateTime(today.year - 1, 12 + month.month);
          }
          dateAmountMap[DateTime(month.year, month.month)] = 0.0;
        }
        break;

      default:
        break;
    }

    return dateAmountMap;
  }

  DateTime _getDateGroup(DateTime date) {
    if (timePeriod == 'Year') {
      return DateTime(date.year, date.month);
    }
    return DateTime(date.year, date.month, date.day);
  }

  String _getTitleForXAxis(double value) {
    DateTime today = DateTime.now();
    DateTime date;

    switch (timePeriod) {
      case 'Week':
        date = today.subtract(Duration(days: (6 - value.toInt())));
        break;
      case 'Month':
        date = today.subtract(Duration(days: (29 - value.toInt())));
        break;
      case 'Year':
        date = DateTime(today.year, today.month - (11 - value.toInt()));
        if (date.month <= 0) {
          date = DateTime(today.year - 1, 12 + date.month);
        }
        break;
      default:
        date = today.subtract(Duration(days: value.toInt()));
    }

    return _formatDate(date);
  }

  String _formatDate(DateTime date) {
    switch (timePeriod) {
      case 'Week':
        return daysOfWeek[date.weekday - 1]; // Mon, Tue, Wed, etc.
      case 'Month':
        return '${date.month.toString()}/${date.day.toString()}'; // month/day
      case 'Year':
        return months[date.month - 1]; // Jan, Feb, Mar, etc.
      default:
        return date.toIso8601String().split('T')[0]; // YYYY-MM-DD
    }
  }

  double _getInterval() {
    if (timePeriod == 'Month') {
      return 5;
    }
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 500,
        height: 500,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
            ),
            titlesData: FlTitlesData(
              show: true,
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 80,
                  getTitlesWidget: (value, meta) =>
                      Text('\$${value.toStringAsFixed(2)}'),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 80,
                  interval: _getInterval(),
                  getTitlesWidget: (value, meta) {
                    return Text(_getTitleForXAxis(value));
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: _prepareData(),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
