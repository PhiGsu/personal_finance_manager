class Transaction {
  final int id;
  final DateTime date;
  final double cost;
  final String description;
  final int categoryId;

  Transaction({
    required this.id,
    required this.date,
    required this.cost,
    required this.description,
    required this.categoryId,
  });

  // Used to simplify insertions into the database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0],
      'cost': cost,
      'description': description,
      'category_id': categoryId
    };
  }
}