class Goal {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime dueDate;
  final int categoryId;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.dueDate,
    required this.categoryId,
  });

  // Used to simplify insertions into the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'due_date': dueDate.toIso8601String().split('T')[0],
      'category_id': categoryId
    };
  }
}