/// User entity for business logic layer
class User {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  @override
  String toString() =>
      'User(id: $id, email: $email, name: $name, createdAt: $createdAt)';
}
