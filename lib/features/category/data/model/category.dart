class Category {
  final int? id;
  final String title;
  final int userId;

  Category({this.id, required this.title, required this.userId});

  // Factory constructor to create a Category from JSON (Map)
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      title: json['title'] as String,
      userId: json['userId'] as int,
    );
  }

  // Convert Category object to JSON (Map)
  Map<String, dynamic> toJson() {
    return {'title': title, 'userId': userId};
  }

  @override
  String toString() => 'Category(id: $id, title: $title, userId: $userId)';
}
