import '../constants/app_strings.dart';
import '../data/demo_seed.dart';
import '../models/experience.dart';
import '../models/user.dart';
import '../utils/anonymous_name.dart';

class AuthState {
  AuthState({
    required List<User> seededUsers,
    this.currentUser,
  }) : _users = List<User>.from(seededUsers);

  final List<User> _users;
  User? currentUser;

  final List<Experience> feedExperiences = <Experience>[];

  bool _demoFeedSeeded = false;

  List<User> get users => List<User>.unmodifiable(_users);

  void seedDemoFeedIfNeeded(bool enabled) {
    if (!enabled || _demoFeedSeeded) return;
    feedExperiences.addAll(buildGlobalDemoExperiencesForSeedUsers());
    _demoFeedSeeded = true;
  }

  User? login({
    required String identifier,
    required String password,
  }) {
    final raw = identifier.trim();
    if (raw.isEmpty) return null;
    final asEmail = raw.toLowerCase();
    for (final user in _users) {
      final matches =
          user.username == raw || user.email.toLowerCase() == asEmail;
      if (matches && user.password == password) {
        currentUser = user;
        return user;
      }
    }
    return null;
  }

  User? signup({
    required String username,
    required String email,
    required String password,
  }) {
    if (usernameExists(username)) return null;
    if (emailExists(email)) return null;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final user = User(
      id: id,
      username: username.trim(),
      email: email.trim().toLowerCase(),
      password: password,
      anonymousHandle: generateAnonymousName(entropy: id.hashCode),
    );
    _users.add(user);
    currentUser = user;
    return user;
  }

  bool usernameExists(String username) {
    final u = username.trim().toLowerCase();
    return _users.any((x) => x.username.toLowerCase() == u);
  }

  bool emailExists(String email) {
    final e = email.trim().toLowerCase();
    if (e.isEmpty) return false;
    return _users.any((x) => x.email.toLowerCase() == e);
  }

  String? updateUsernameForCurrentUser(String next) {
    final u = currentUser;
    if (u == null) return AppStrings.profileErrorNotSignedIn;
    final t = next.trim();
    if (t.isEmpty) return AppStrings.authValidationUsername;
    if (usernameExists(t) && t.toLowerCase() != u.username.toLowerCase()) {
      return AppStrings.authValidationUsernameTaken;
    }
    u.username = t;
    return null;
  }

  String? changePasswordForCurrentUser({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    final u = currentUser;
    if (u == null) return AppStrings.profileErrorNotSignedIn;
    if (u.password != currentPassword) {
      return AppStrings.profileErrorWrongPassword;
    }
    if (newPassword.length < 4) {
      return AppStrings.authValidationPasswordShort;
    }
    if (newPassword != confirmPassword) {
      return AppStrings.authValidationPasswordMismatch;
    }
    u.password = newPassword;
    return null;
  }

  static bool isValidEmailFormat(String raw) {
    final e = raw.trim().toLowerCase();
    return e.contains('@') && e.length > 4 && e.split('@').length == 2;
  }

  void logout() {
    currentUser = null;
  }
}
