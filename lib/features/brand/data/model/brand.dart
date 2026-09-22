class Brand {
  final int? id;
  final String name;
  // final String? code;
  // final String? description;

  Brand({
    this.id,
    required this.name,
    // this.code,
    // this.logoUrl,
    // this.description
  });

  // Factory constructor to create a Brand from JSON (Map)
  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int?,
      name: json['name'] as String,
      // code: json['code'] as String?,
      // logoUrl: json['logoUrl'] as String?,
      // description: json['description'] as String?
    );
  }

  // Convert Brand object to JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      // if (code != null) 'code': code,
      // if (logoUrl != null) 'logoUrl': logoUrl,
      // if (description != null) 'description': description,
    };
  }
}
