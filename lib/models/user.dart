class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.anonymousHandle,
  });

  final String id;
  String username;
  String email;
  String password;
  String anonymousHandle;
}
