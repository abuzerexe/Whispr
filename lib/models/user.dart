class User {
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.anonymousHandle,
  });

  final String id;
  String username;
  final String email;
  final String anonymousHandle;

  factory User.fromFirestore(String uid, Map<String, dynamic> data) {
    return User(
      id: uid,
      username: data['username'] as String? ?? '',
      email: data['email'] as String? ?? '',
      anonymousHandle: data['anonymousHandle'] as String? ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'username': username,
        'email': email,
        'anonymousHandle': anonymousHandle,
      };
}
