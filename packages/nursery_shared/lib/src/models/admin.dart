class Admin {
  const Admin({
    required this.id,
    required this.fullName,
    required this.email,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final DateTime createdAt;

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'created_at': createdAt.toIso8601String(),
      };
}
