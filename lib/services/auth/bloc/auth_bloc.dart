import 'package:bloc/bloc.dart';
import 'package:mynotes/services/auth/auth_provider.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider authProvider) : super(const AuthStateUnInitialized()) {
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
        emit(const AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });

    // initialize
    on<AuthEventInitialize>(
      ((event, emit) async {
        await authProvider.initialize();
        final user = authProvider.currentUser;
        if (user == null) {
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
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
        emit(const AuthStateLoggedOut(exception: null, isLoading: true));
        final email = event.email;
        final password = event.password;
        try {
          final user = await authProvider.logIn(
            email: email,
            password: password,
          );

          emit(const AuthStateLoggedOut(exception: null, isLoading: false));

          if(!user.isEmailVerified){
            emit(const AuthStateNeedsVerification());
          } else {
            emit(AuthStateLoggedIn(user));
          }

        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      }),
    );

    // log out
    on<AuthEventLogOut>(
      ((event, emit) async {
        try{
          authProvider.logOut();
          emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        } on Exception catch (e) {
          emit(AuthStateLoggedOut(exception: e, isLoading: false));
        }
      }),
    );
  }
}
