import 'package:firebase_core/firebase_core.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(
        provider.isInitialized,
        false,
      );
    });

    test('Cannot sign out if not initialized', () {
      expect(
        provider.signOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test('Should be able to be initialized', () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test('User should be null after initialization', () {
      expect(provider.currentUser, null);
    });

    test(
      'Should be able to initialize in less than 2 seconds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test(
      'Create user should delegate to signin function',
      () async {
        final badEmailUser = provider.createUser(
          email: 'foo@bar.com',
          password: 'anypassword',
        );
        expect(badEmailUser,
            throwsA(const TypeMatcher<UserNotFoundAuthException>()));

        final badPasswordUser = provider.createUser(
          email: 'someone@email.com',
          password: 'foobar',
        );
        expect(
          badPasswordUser,
          throwsA(const TypeMatcher<WrongPassswordAuthException>()),
        );

        final user = await provider.createUser(
          email: 'someone@email.com',
          password: 'someonepassword',
        );
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, false);
      },
    );

    test(
      'Signed in user shoudld be able to get verified',
      () {
        provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      },
    );

    test(
      'Should be able to sign out and sign in again',
      () async {
        await provider.signOut();
        await provider.signIn(
          email: 'email',
          password: 'password',
        );
        expect(provider.currentUser, isNotNull);
      },
    );
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  var _isInitialized = false;
  AuthUser? _user;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
    await Future.delayed(const Duration(seconds: 1));
    return signIn(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
    return;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    const newUser = AuthUser(id: 'my_id', isEmailVerified: true, email: 'foo@bar.baz');
    _user = newUser;
  }

  @override
  Future<AuthUser> signIn({required String email, required String password}) {
    if (!isInitialized) throw NotInitializedException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPassswordAuthException();
    const user = AuthUser(id: 'my_id', isEmailVerified: false, email: 'foo@bar.baz');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> signOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }
}
