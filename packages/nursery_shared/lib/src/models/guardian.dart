class Guardian {
  const Guardian({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.authProvider,
    required this.createdAt,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String authProvider; // 'email' | 'google' | 'apple'
  final DateTime createdAt;

  factory Guardian.fromJson(Map<String, dynamic> json) {
    return Guardian(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      authProvider: json['auth_provider'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'auth_provider': authProvider,
        'created_at': createdAt.toIso8601String(),
      };
}
