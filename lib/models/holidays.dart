class HolidayModel {
  final String name;
  final String title;
  final bool isCheck;
  HolidayModel({
    required this.name,
    required this.title,
    required this.isCheck,
  });

  HolidayModel copyWith({String? name, String? title, bool? isCheck}) {
    return HolidayModel(
      name: name ?? this.name,
      title: title ?? this.title,
      isCheck: isCheck ?? this.isCheck,
    );
  }
}
