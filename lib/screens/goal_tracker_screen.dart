import 'package:flutter/material.dart';
import 'package:personal_finance_manager/main.dart';

class GoalTrackerScreen extends StatefulWidget {
  const GoalTrackerScreen({super.key});

  @override
  State<GoalTrackerScreen> createState() => _GoalTrackerScreenState();
}

class _GoalTrackerScreenState extends State<GoalTrackerScreen> {
  final List<Map<String, dynamic>> _goals = [];
  double totalSavings = 0; // Tracks the total savings

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a Goal"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Max Value"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final title = titleController.text;
                final maxValue = int.tryParse(valueController.text) ?? 0;
                if (title.isNotEmpty && maxValue > 0) {
                  setState(() {
                    _goals.add({
                      "title": title,
                      "maxValue": maxValue,
                      "currentValue": 0,
                    });
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateGoalDialog(Map<String, dynamic> goal) {
    final updateController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Goal"),
          content: TextField(
            controller: updateController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Add/Remove Value"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final updateValue = int.tryParse(updateController.text) ?? 0;
                setState(() {
                  // Update the current value
                  final newValue = (goal["currentValue"] + updateValue)
                      .clamp(0, goal["maxValue"]);
                  // Update the total savings
                  totalSavings += newValue - goal["currentValue"];
                  goal["currentValue"] = newValue;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  void _deleteGoal(Map<String, dynamic> goal) {
    setState(() {
      totalSavings -=
          goal["currentValue"]; // Subtract currentValue from totalSavings
      _goals.remove(goal); // Remove the goal from the list
    });
  }

  Color _getBarColor(double ratio) {
    if (ratio <= 1 / 3) {
      return const Color(0xFFFFCDD2); // Light red
    } else if (ratio <= 2 / 3) {
      return const Color(0xFFFFF9C4); // Light yellow
    } else {
      return const Color(0xFFC8E6C9); // Light green
    }
  }

  Color _getBarOutlineColor(double ratio) {
    if (ratio <= 1 / 3) {
      return Colors.red; // Dark red outline
    } else if (ratio <= 2 / 3) {
      return Colors.yellow; // Dark yellow outline
    } else {
      return Colors.green; // Dark green outline
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinanceMangerAppBar(),
      drawer: const FinanceMangerAppDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 10), // Spacing below AppBar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 3,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: Color(0xFF144664)),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Goal Tracker',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10), // Additional spacing
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 60.0), // Increased padding
              child: Text(
                'Total Savings: \$${totalSavings.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _goals.map((goal) {
                  final ratio = goal["currentValue"] / goal["maxValue"];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 60.0), // Adjusted horizontal margin
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goal["title"],
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteGoal(goal),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Stack(
                            children: [
                              Container(
                                height: 20.0,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: ratio,
                                child: Container(
                                  height: 20.0,
                                  decoration: BoxDecoration(
                                    color: _getBarColor(ratio),
                                    border: Border.all(
                                      color: _getBarOutlineColor(ratio),
                                      width: 1.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "\$${goal["currentValue"]}/\$${goal["maxValue"]}", // Add '$' before numbers
                              style: const TextStyle(fontSize: 12.0),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    const Color(0xFFDAE8FC)), // Blue background
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                padding: WidgetStateProperty.all(
                                    const EdgeInsets.all(
                                        8.0)), // Proper padding
                              ),
                              onPressed: () => _showUpdateGoalDialog(goal),
                              child: const Icon(Icons.edit,
                                  color: Colors.black), // Black edit icon
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        child: const Icon(Icons.add),
        backgroundColor: const Color(0xFFDAE8FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
