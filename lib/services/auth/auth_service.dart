import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;

  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<FirebaseApp> initialize() async {
    return provider.initialize();
  }

  @override
  Future<AuthUser> createUser({required String email, required String password,}) {
    return provider.createUser(email: email, password: password);
  }

  @override
  AuthUser? get currentUSer => provider.currentUSer;

  @override
  Future<void> sendEmailVerification() {
    return provider.sendEmailVerification();
  }

  @override
  Future<AuthUser> signIn({required String email, required String password,}) {
    return provider.signIn(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return provider.signOut();
  }
}