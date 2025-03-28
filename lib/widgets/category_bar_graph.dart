import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:personal_finance_manager/models/user_transaction.dart';

class CategoryBarGraph extends StatelessWidget {
  final List<UserTransaction> transactions;
  final Map<int, String> categories;

  static List<Color> barColors = [
    Colors.yellowAccent,
    Colors.lightBlueAccent,
    Colors.orangeAccent,
    Colors.greenAccent,
    Colors.pinkAccent,
  ];

  const CategoryBarGraph(
      {super.key, required this.transactions, required this.categories});

  Map<int, double> _getCategoryData() {
    Map<int, double> categoryTotalMap = {};

    for (var transaction in transactions) {
      if (categoryTotalMap.containsKey(transaction.categoryId)) {
        categoryTotalMap[transaction.categoryId] =
            categoryTotalMap[transaction.categoryId]! + transaction.amount;
      } else {
        categoryTotalMap[transaction.categoryId] = transaction.amount;
      }
    }

    return categoryTotalMap;
  }

  @override
  Widget build(BuildContext context) {
    Map<int, double> categoryData = _getCategoryData();

    List<BarChartGroupData> barGroups = categoryData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: barColors[entry.key % barColors.length],
            width: 20,
          ),
        ],
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 500,
        child: BarChart(
          BarChartData(
            barGroups: barGroups,
            titlesData: FlTitlesData(
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
                  maxIncluded: false,
                  minIncluded: false,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 80,
                  getTitlesWidget: (value, meta) {
                    return Text(categories[value]!);
                  },
                ),
              ),
            ),
            gridData: const FlGridData(drawVerticalLine: false),
          ),
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
        ),
      ),
    );
  }
}
