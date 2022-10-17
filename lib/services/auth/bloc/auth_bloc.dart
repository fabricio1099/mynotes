import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

import 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider authProvider) : super(const AuthStateLoading()) {
    // initialize
    on<AuthEventInitialize>(
      ((event, emit) async {
        await authProvider.initialize();
        final user = authProvider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut());
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(user));
        }
      }),
    );

    // log in
    on<AuthEventLogIn>(
      ((event, emit) async {
        emit(const AuthStateLoading());
        final email = event.email;
        final password = event.password;

        try {
          final user = await authProvider.logIn(
            email: email,
            password: password,
          );
          emit(AuthStateLoggedIn(user));
        } on Exception catch (e) {
          emit(AuthStateLoginFailure(e));
        }
      }),
    );

    // log out
    on<AuthEventLogOut>(
      ((event, emit) async {
        try {
          emit(const AuthStateLoading());
          await authProvider.logOut();
          emit(const AuthStateLoggedOut());
        } on Exception catch (e) {
          emit(AuthStateLogoutFailure(e));
        }
      }),
    );
  }
}
