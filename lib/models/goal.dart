class Goal {
  final int? id;
  final String name;
  final double targetAmount;
  double currentAmount;

  Goal({
    this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0,
  });

  // Used to simplify insertions into the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
    };
  }
}