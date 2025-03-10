import 'package:flutter/material.dart';
import 'package:personal_finance_manager/screens/spending_analysis_screen.dart';
import 'package:personal_finance_manager/screens/transaction_log_screen.dart';
import 'package:personal_finance_manager/screens/goal_tracker_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Finance Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFA3BFA8)),
        useMaterial3: true,
      ),
      home: const SpendingAnalysisScreen(),
    );
  }
}

// Appbar to be used across all screens
class FinanceMangerAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const FinanceMangerAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text('Personal Finance Manager'),
      centerTitle: true,
      leading: IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(Icons.menu)),
    );
  }
}

// Hamburger menu navigation items to be used across all screens
class FinanceMangerAppDrawer extends StatelessWidget {
  const FinanceMangerAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.analytics),
            title: const Text('Spending Analysis'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SpendingAnalysisScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.list_alt),
            title: const Text('Transaction Log'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TransactionLogScreen()));
            },
          ),
          ListTile(
            leading: Icon(Icons.track_changes),
            title: const Text('Goal Tracker'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => GoalTrackerScreen()));
            },
          ),
        ],
      ),
    );
  }
}
