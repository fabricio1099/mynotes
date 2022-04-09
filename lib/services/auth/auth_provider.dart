import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<FirebaseApp> initialize();

  AuthUser? get currentUSer;

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> createUser({required String email, required String password});

  Future<void> signOut();

  Future<void> sendEmailVerification();
}
