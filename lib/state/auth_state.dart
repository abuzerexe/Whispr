import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/user.dart';
import '../services/firestore_service.dart';
import '../utils/anonymous_name.dart';

class AuthState {
  final _auth = fb.FirebaseAuth.instance;
  final _firestore = FirestoreService.instance;

  User? currentUser;

  /// Loads the signed-in Firebase user plus their Firestore profile. If Auth
  /// has a session but the profile doc is missing, creates it (first-time /
  /// recovery after rules were fixed).
  Future<User?> loadCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    final err = await _hydrateProfile(fbUser);
    if (err != null) {
      await _auth.signOut();
      currentUser = null;
      return null;
    }
    return currentUser;
  }

  /// Signs in with email + password. Returns an error string or null on success.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final err = await _hydrateProfile(cred.user!);
      if (err != null) {
        await _auth.signOut();
        currentUser = null;
      }
      return err;
    } on fb.FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    } catch (_) {
      await _auth.signOut();
      currentUser = null;
      return 'Could not finish signing in. Check your connection and try again.';
    }
  }

  /// Creates a Firebase Auth account, generates an anonymous handle, writes the
  /// user profile to Firestore. Deletes the Auth user if Firestore write fails.
  Future<String?> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    fb.UserCredential? cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      final uid = cred.user!.uid;
      final handle = generateAnonymousName(entropy: uid.hashCode);
      final user = User(
        id: uid,
        username: username.trim(),
        email: email.trim().toLowerCase(),
        anonymousHandle: handle,
      );
      await _firestore.createUser(user);
      currentUser = user;
      return null;
    } on fb.FirebaseAuthException catch (e) {
      currentUser = null;
      return _errorMessage(e.code);
    } on FirebaseException catch (e) {
      await _rollbackPartialSignup(cred);
      currentUser = null;
      return _firestoreMessage(e.code);
    } catch (_) {
      await _rollbackPartialSignup(cred);
      currentUser = null;
      return 'Could not complete sign-up. Try again.';
    }
  }

  Future<void> _rollbackPartialSignup(fb.UserCredential? cred) async {
    try {
      await cred?.user?.delete();
    } catch (_) {
      /* best-effort */
    }
    await _auth.signOut();
  }

  /// Loads [currentUser] from Firestore or creates the missing profile doc.
  /// Returns null on success, or an error message.
  Future<String?> _hydrateProfile(fb.User fbUser) async {
    try {
      var profile = await _firestore.getUser(fbUser.uid);
      profile ??= await _createFirestoreProfileFromAuth(fbUser);
      currentUser = profile;
      return null;
    } on FirebaseException catch (e) {
      return _firestoreMessage(e.code);
    } catch (_) {
      return 'Could not load your profile. Check your connection.';
    }
  }

  Future<User> _createFirestoreProfileFromAuth(fb.User fbUser) async {
    final email = (fbUser.email ?? '').trim().toLowerCase();
    final localPart = email.split('@').first;
    final username = localPart.isEmpty ? 'user' : localPart;
    final user = User(
      id: fbUser.uid,
      username: username,
      email: email,
      anonymousHandle: generateAnonymousName(entropy: fbUser.uid.hashCode),
    );
    await _firestore.createUser(user);
    return user;
  }

  Future<String?> updateUsernameForCurrentUser(String next) async {
    final u = currentUser;
    if (u == null) return 'Not signed in.';
    final t = next.trim();
    if (t.isEmpty) return 'Enter a username.';
    try {
      await _firestore.updateUsername(u.id, t);
      u.username = t;
      return null;
    } catch (_) {
      return 'Could not save username. Please try again.';
    }
  }

  Future<String?> changePasswordForCurrentUser({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return 'Not signed in.';
    if (newPassword.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    if (newPassword != confirmPassword) return 'Passwords do not match.';
    try {
      final cred = fb.EmailAuthProvider.credential(
        email: fbUser.email!,
        password: currentPassword,
      );
      await fbUser.reauthenticateWithCredential(cred);
      await fbUser.updatePassword(newPassword);
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return _errorMessage(e.code);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
  }

  static bool isValidEmailFormat(String raw) {
    final e = raw.trim().toLowerCase();
    return e.contains('@') && e.length > 4 && e.split('@').length == 2;
  }

  static String _firestoreMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Firestore blocked this request (check security rules in '
            'Firebase Console).';
      case 'unavailable':
        return 'The service is temporarily unavailable. Try again.';
      case 'failed-precondition':
      case 'not-found':
        return 'Firestore may not be enabled for this project. In Firebase '
            'Console → Build → Firestore Database → Create database.';
      default:
        return 'Could not sync with the server.';
    }
  }

  static String _errorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/Password sign-in is not enabled. Enable it in '
            'Firebase Console → Authentication → Sign-in method.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'configuration-not-found':
        return 'Firebase project not configured correctly. Check your '
            'Firebase Console settings.';
      default:
        return 'Authentication failed ($code). Please try again.';
    }
  }
}
