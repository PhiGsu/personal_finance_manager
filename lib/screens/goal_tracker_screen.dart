import 'package:flutter/material.dart';
import 'package:personal_finance_manager/main.dart';

class GoalTrackerScreen extends StatelessWidget {
  const GoalTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinanceMangerAppBar(),
      drawer: const FinanceMangerAppDrawer(),
      body: const Center(
        child: Text('Welcome to Goal Tracker Screen!'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0), // Adds spacing around the button
        child: SizedBox(
          width: 48, // Sets the width of the square
          height: 48, // Sets the height of the square
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color.fromARGB(255, 218, 232, 252), // Custom hex color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    8.0), // Square shape with slight rounding
              ),
              padding: EdgeInsets.zero, // No extra padding inside
            ),
            onPressed: () {
              // Add your button press logic here
              print('Square button with a plus icon pressed!');
            },
            child: const Icon(
              Icons.add, // Plus icon
              color: Colors.black, // Icon color
              size: 32.0,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Bottom right position
    );
  }
}
