import 'package:mynotes/services/auth/auth_user.dart';

abstract class AuthProvider {
  Future<void> initialize();

  AuthUser? get currentUSer;

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> createUser({required String email, required String password});

  Future<void> signOut();

  Future<void> sendEmailVerification();
}
