/// User entity for business logic layer
class User {

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;

  @override
  String toString() =>
      'User(id: $id, email: $email, name: $name, createdAt: $createdAt)';
}
