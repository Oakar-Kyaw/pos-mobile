class CreateLeaveRequest {
  final DateTime date;
  final String title;
  final String? imageUrl;

  CreateLeaveRequest({required this.date, required this.title, this.imageUrl});

  Map<String, dynamic> toJson() {
    return {
      "date": date.toIso8601String(),
      "title": title,
      "imageUrl": imageUrl,
    };
  }
}
