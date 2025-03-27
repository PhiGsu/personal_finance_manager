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

  // Group transactions by date and sum their costs
  List<FlSpot> _prepareData() {
    Map<DateTime, double> dateCostMap = _initializeDateMap();

    for (var transaction in transactions) {
      DateTime dateKey = _getDateGroup(transaction.date);
      if (dateCostMap.containsKey(dateKey)) {
        dateCostMap[dateKey] = dateCostMap[dateKey]! + transaction.cost;
      }
    }

    // Map entries sorted by date descending
    List<MapEntry<DateTime, double>> sortedEntries =
        dateCostMap.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    double calculatedBalance = balance;

    return sortedEntries.map((entry) {
      FlSpot flSpot = FlSpot(
          entry.key.millisecondsSinceEpoch.toDouble(), calculatedBalance);
      calculatedBalance -= entry.value;
      return flSpot;
    }).toList();
  }

  Map<DateTime, double> _initializeDateMap() {
    Map<DateTime, double> dateCostMap = {};
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    switch (timePeriod) {
      case 'Week':
        for (int i = 0; i < 7; i++) {
          dateCostMap[today.subtract(Duration(days: i))] = 0.0;
        }
        break;

      case 'Month':
        for (int i = 0; i < 30; i++) {
          dateCostMap[today.subtract(Duration(days: i))] = 0.0;
        }
        break;

      case 'Year':
        for (int i = 0; i < 12; i++) {
          DateTime month = DateTime(today.year, today.month - i);
          if (month.month <= 0) {
            month = DateTime(today.year - 1, 12 + month.month);
          }
          dateCostMap[DateTime(month.year, month.month)] = 0.0;
        }
        break;

      default:
        break;
    }

    return dateCostMap;
  }

  DateTime _getDateGroup(DateTime date) {
    if (timePeriod == 'Year') {
      return DateTime(date.year, date.month);
    }
    return DateTime(date.year, date.month, date.day);
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
    switch (timePeriod) {
      case 'Week':
        return Duration.millisecondsPerDay.toDouble();
      case 'Month':
        return Duration.millisecondsPerDay.toDouble() * 5;
      case 'Year':
        return Duration.millisecondsPerDay.toDouble() * 30;
      default:
        return Duration.millisecondsPerDay.toDouble();
    }
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
                  minIncluded: false,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 80,
                  minIncluded: false,
                  maxIncluded: false,
                  interval: _getInterval(),
                  getTitlesWidget: (value, meta) {
                    DateTime date =
                        DateTime.fromMillisecondsSinceEpoch(value.toInt());
                    return Text(_formatDate(date));
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
