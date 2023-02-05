import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mynotes/helpers/loading/loading_screen.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';
import 'package:mynotes/views/forgot_password_view.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/home_view.dart';
import 'package:mynotes/views/notes/profile_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'views/verify_email_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.nunitoTextTheme(),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        CreateUpdateNoteView.routeName: (context) =>
            const CreateUpdateNoteView(),
        ProfileView.routeName: (context) => const ProfileView(),
      },
    ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return SafeArea(
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: ((context, state) {
          if (state.isLoading) {
            LoadingScreen().show(
              context: context,
              text: state.loadingText ?? 'Please wait a moment',
            );
          } else {
            LoadingScreen().hide();
          }
        }),
        builder: (context, state) {
          if (state is AuthStateLoggedIn) {
            return const Home();
          } else if (state is AuthStateNeedsVerification) {
            return const VerifyEmailView();
          } else if (state is AuthStateLoggedOut) {
            return const LoginView();
          } else if (state is AuthStateRegistering) {
            return const RegisterView();
          } else if (state is AuthStateForgotPassword) {
            return const ForgotPasswordView();
          } else {
            return const Scaffold(
              body: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}