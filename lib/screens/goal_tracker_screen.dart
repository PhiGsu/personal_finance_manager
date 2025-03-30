import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:personal_finance_manager/database.dart';
import 'package:personal_finance_manager/main.dart';
import 'package:personal_finance_manager/models/goal.dart';

class GoalTrackerScreen extends StatefulWidget {
  const GoalTrackerScreen({super.key});

  @override
  State<GoalTrackerScreen> createState() => _GoalTrackerScreenState();
}

class _GoalTrackerScreenState extends State<GoalTrackerScreen> {
  final _addFormKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();
  List<Goal> _goals = [];
  double totalSavings = 0;

  late final TextEditingController titleController;
  late final TextEditingController valueController;
  late final TextEditingController updateController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    valueController = TextEditingController();
    updateController = TextEditingController();
    _loadData();
  }

  @override
  void dispose() {
    titleController.dispose();
    valueController.dispose();
    updateController.dispose();
    super.dispose();
  }

  void _loadData() async {
    final goals = await DatabaseHelper.instance.getGoals();
    final total = goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
    setState(() {
      _goals = goals;
      totalSavings = total;
    });
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add a Goal"),
          content: Form(
            key: _addFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.length > 50) {
                      return 'Title must be less than 50 characters';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: valueController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Max Value"),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a max value';
                    }
                    final maxValue = double.tryParse(value);
                    if (maxValue == null || maxValue <= 0) {
                      return 'Please enter a valid number';
                    }
                    if (maxValue >= 100_000_000_000) {
                      return 'Value cannot exceed 100 billion';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (_addFormKey.currentState?.validate() ?? false) {
                  final goal = Goal(
                    name: titleController.text,
                    targetAmount: double.tryParse(valueController.text) ?? 0,
                  );
                  Navigator.of(context).pop();
                  goal.id = await DatabaseHelper.instance
                      .insert('Goal', goal.toMap());
                  setState(() {
                    _goals.add(goal);
                  });
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    ).then((_) {
      titleController.clear();
      valueController.clear();
    });
  }

  void _showUpdateGoalDialog(Goal goal) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Goal"),
          content: Form(
            key: _updateFormKey,
            child: TextFormField(
              controller: updateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Add/Remove Value",
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a value';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
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
                if (_updateFormKey.currentState?.validate() ?? false) {
                  final updateValue =
                      double.tryParse(updateController.text) ?? 0;
                  final double newValue = (goal.currentAmount + updateValue)
                      .clamp(0, goal.targetAmount);
                  setState(() {
                    // Update the total savings
                    totalSavings += newValue - goal.currentAmount;
                    goal.currentAmount = newValue;
                  });
                  DatabaseHelper.instance.update('Goal', goal.toMap());
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    ).then((_) {
      updateController.clear();
    });
  }

  void _showDeleteDialog(Goal goal) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this goal?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  totalSavings -= goal.currentAmount;
                  _goals.remove(goal);
                });
                DatabaseHelper.instance.delete('Goal', goal.id!);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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
      return Colors.red;
    } else if (ratio <= 2 / 3) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FinanceMangerAppBar(),
      drawer: const FinanceMangerAppDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60.0),
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
                  final ratio = goal.currentAmount / goal.targetAmount;
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 60.0,
                    ),
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
                              Flexible(
                                child: Text(
                                  goal.name,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteDialog(goal),
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
                              "\$${goal.currentAmount.toStringAsFixed(2)}/\$${goal.targetAmount.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 12.0),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                  const Color(0xFFDAE8FC),
                                ),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                padding: WidgetStateProperty.all(
                                  const EdgeInsets.all(8.0),
                                ),
                              ),
                              onPressed: () => _showUpdateGoalDialog(goal),
                              child:
                                  const Icon(Icons.edit, color: Colors.black),
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
        backgroundColor: const Color(0xFFDAE8FC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
