class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String phone;
  final DateTime birthDate;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.phone,
    required this.birthDate,
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? phone,
    DateTime? birthDate,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
