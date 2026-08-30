/// The signed-in admin's own profile, from `GET /api/account/me`.
///
/// The API also returns `email`, but the admin app has no use for it and
/// deliberately does not read or display it.
class Account {
  const Account({
    required this.id,
    required this.fullName,
    required this.userName,
    required this.role,
    this.phoneNumber,
  });

  final String id;
  final String fullName;
  final String userName;
  final String role;
  final String? phoneNumber;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      fullName: json['fullName'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      role: json['role'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
    );
  }

  Account copyWith({String? fullName, String? phoneNumber}) => Account(
        id: id,
        fullName: fullName ?? this.fullName,
        userName: userName,
        role: role,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );
}
