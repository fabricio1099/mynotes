import 'package:mynotes/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUSer;

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> createUser({required String email, required String password});

  Future<void> signout();

  Future<void> sendEmailVerification();
}
