class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime? dueDate;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.dueDate,
  });

  // Used to simplify insertions into the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'due_date': dueDate?.toIso8601String().split('T')[0],
    };
  }
}