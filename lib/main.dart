import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart';
import 'package:mynotes/views/notes_view.dart';
import 'package:mynotes/views/register_view.dart';
import 'dart:developer' as d show log;

import 'views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        RegisterView.routeName: (context) => const RegisterView(),
        LoginView.routeName: (context) => const LoginView(),
        NotesView.routeName: (context) => const NotesView(),
        VerifyEmailView.routeName: (context) => const VerifyEmailView(),
        CreateUpdateNoteView.routeName: (context) =>
            const CreateUpdateNoteView(),
      },
    ),
  );
}

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<void>(
//       future: AuthService.firebase().initialize(),
//       builder: (context, snapshot) {
//         switch (snapshot.connectionState) {
//           case ConnectionState.done:
//             final user = AuthService.firebase().currentUser;
//             if (user == null) {
//               return const LoginView();
//             } else if (user.isEmailVerified) {
//               d.log('You are a verified user');
//               return const NotesView();
//             } else {
//               d.log('You need to verify your email first !');
//               return const VerifyEmailView();
//             }
//           default:
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: const [
//                 CircularProgressIndicator(),
//                 Text('Loading...'),
//               ],
//             );
//         }
//       },
//     );
//   }
// }

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TextEditingController _textController;

  @override
  void initState() {
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Testing bloc'),
        ),
        body: BlocConsumer<CounterBloc, CounterState>(
          listener: (context, state) {
            _textController.clear();
          },
          builder: (context, state) {
            final invalidValue =
                (state is CounterStateInValidNumber) ? state.invalidValue : '';
            return Column(
              children: [
                Text('Current value : ${state.value}'),
                Visibility(
                  child: Text('Invalid input: $invalidValue'),
                  visible: state is CounterStateInValidNumber,
                ),
                TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Enter a number here',
                  ),
                  keyboardType: TextInputType.number,
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBloc>()
                            .add(DecrementEvent(_textController.text));
                      },
                      child: const Text('-'),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<CounterBloc>()
                            .add(IncrementEvent(_textController.text));
                      },
                      child: const Text('+'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

@immutable
abstract class CounterState {
  final int value;
  const CounterState(this.value);
}

class CounterStateValid extends CounterState {
  const CounterStateValid(int value) : super(value);
}

class CounterStateInValidNumber extends CounterState {
  final String invalidValue;
  const CounterStateInValidNumber({
    required this.invalidValue,
    required int previousValue,
  }) : super(previousValue);
}

@immutable
abstract class CounterEvent {
  final String value;
  const CounterEvent(this.value);
}

class IncrementEvent extends CounterEvent {
  const IncrementEvent(String value) : super(value);
}

class DecrementEvent extends CounterEvent {
  const DecrementEvent(String value) : super(value);
}

class CounterBloc extends Bloc<CounterEvent, CounterState> {
  CounterBloc() : super(const CounterStateValid(0)) {
    on<IncrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(
          CounterStateInValidNumber(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(
          CounterStateValid(state.value + integer),
        );
      }
    });

    on<DecrementEvent>((event, emit) {
      final integer = int.tryParse(event.value);
      if (integer == null) {
        emit(
          CounterStateInValidNumber(
            invalidValue: event.value,
            previousValue: state.value,
          ),
        );
      } else {
        emit(
          CounterStateValid(state.value - integer),
        );
      }
    });
  }
}
