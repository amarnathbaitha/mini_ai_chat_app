import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mini_ai_chat_app/feature/auth/bloc/auth_bloc.dart';

import 'feature/auth/bloc/auth_event.dart';
import 'feature/auth/bloc/auth_state.dart';
import 'feature/auth/data/auth_repository.dart';
import 'feature/auth/data/user_repository.dart';
import 'feature/auth/presentation/login_page.dart';
import 'feature/chat/data/chat_repository.dart';
import 'feature/chat/presentation/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => UserRepository()),
        RepositoryProvider(create: (_) => ChatRepository()),
      ],
      child: BlocProvider(
        create: (context) => AuthBloc(
          context.read<AuthRepository>(),
          context.read<UserRepository>(),
        )..add(AppStarted()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Chat Assignment',
          theme: ThemeData(
            colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {

        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthAuthenticated) {
          return HomePage();
        }

        if (state is AuthUnauthenticated) {
          return const LoginPage();
        }

        if (state is AuthError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

