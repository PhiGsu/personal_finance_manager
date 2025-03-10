class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  // Used to simplify insertions into the database
  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}