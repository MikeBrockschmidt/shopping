import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw AuthException('Das Passwort ist zu schwach.');
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Diese E-Mail-Adresse ist bereits registriert.');
      }
      throw AuthException(
        e.message ?? 'Ein unbekannter Registrierungsfehler ist aufgetreten.',
      );
    } catch (e) {
      throw AuthException(
        'Ein unerwarteter Fehler ist aufgetreten: ${e.toString()}',
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw AuthException('Kein Benutzer mit dieser E-Mail gefunden.');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Falsches Passwort.');
      }
      throw AuthException(
        e.message ?? 'Ein unbekannter Anmeldefehler ist aufgetreten.',
      );
    } catch (e) {
      throw AuthException(
        'Ein unerwarteter Fehler ist aufgetreten: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<void> sendEmailVerification() async {
    await _firebaseAuth.currentUser?.sendEmailVerification();
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
