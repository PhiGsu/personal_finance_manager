class UserTransaction {
  final int? id;
  final DateTime date;
  final double amount;
  final String description;
  final int categoryId;

  UserTransaction({
    required this.date,
    required this.amount,
    required this.description,
    required this.categoryId,
    this.id,
  });

  // Used to simplify insertions into the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'amount': amount,
      'description': description,
      'category_id': categoryId
    };
  }
}