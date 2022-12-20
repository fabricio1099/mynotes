import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider authProvider)
      : super(const AuthStateUnInitialized(isLoading: true)) {
        
    // send email verification
    on<AuthEventSendEmaiVerification>((event, emit) async {
      await authProvider.sendEmailVerification();
      emit(state);
    });

    // register
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await authProvider.createUser(email: email, password: password);
        await authProvider.sendEmailVerification();
        emit(const AuthStateNeedsVerification(
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
          isLoading: false,
        ));
      }
    });

    // initialize
    on<AuthEventInitialize>(
      ((event, emit) async {
        await authProvider.initialize();
        final user = authProvider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
            showPassword: false,
          ));
        } else if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification(
            isLoading: false,
          ));
        } else {
          emit(AuthStateLoggedIn(
            user: user,
            isLoading: false,
          ));
        }
      }),
    );

    // log in
    on<AuthEventLogIn>(
      ((event, emit) async {
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
          loadingText: 'Please wait while I log you in',
          showPassword: false,
        ));
        final email = event.email;
        final password = event.password;
        try {
          final user = await authProvider.logIn(
            email: email,
            password: password,
          );

          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
            showPassword: false,
          ));

          if (!user.isEmailVerified) {
            emit(const AuthStateNeedsVerification(
              isLoading: false,
            ));
          } else {
            emit(AuthStateLoggedIn(
              user: user,
              isLoading: false,
            ));
          }
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(
            exception: e,
            isLoading: false,
            showPassword: false,
          ));
        }
      }),
    );

    // log out
    on<AuthEventLogOut>(
      ((event, emit) async {
        final loggedIn = state.loggedIn;
        try {
          if (loggedIn) {
            authProvider.logOut();
          }
          emit(const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
            showPassword: false,
          ));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(
            exception: e,
            isLoading: false,
            showPassword: false,
          ));
        }
      }),
    );

    // forgot password
    on<AuthEventForgotPassword>(
      (event, emit) async {
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: false,
        ));

        final email = event.email;
        if (email == null) {
          return; // user just wants to go to forgot-password screen
        }

        // user wants to actually send a forgot-password email
        emit(const AuthStateForgotPassword(
          exception: null,
          hasSentEmail: false,
          isLoading: true,
        ));

        bool didSendEmail;
        Exception? exception;
        try {
          authProvider.sendPasswordReset(toEmail: email);
          didSendEmail = true;
          exception = null;
        } on Exception catch (e) {
          didSendEmail = false;
          exception = e;
        }
        emit(AuthStateForgotPassword(
          exception: exception,
          hasSentEmail: didSendEmail,
          isLoading: false,
        ));
      },
    );

    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(
        exception: null,
        isLoading: false,
      ));
    });

    on<AuthEventLoginShowPassword>((event, emit) {
      final showPassword = event.showPassword;
      emit(AuthStateLoggedOut(
        exception: null,
        isLoading: false,
        showPassword: showPassword,
      ));
    });
  }
}
