import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mini_ai_chat_app/feature/auth/data/auth_repository.dart';
import 'package:mini_ai_chat_app/feature/auth/data/user_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthBloc(this._authRepository, this._userRepository) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SignInAnonymouslyRequested>(_onAnonymousSignIn);
    on<SignInWithGoogleRequested>(_onGoogleSignIn);
    on<SignOutRequested>(_onSignOut);
  }

  Future<void> _onAppStarted(
      AppStarted event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }


  Future<void> _onAnonymousSignIn(
      SignInAnonymouslyRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {

      final user = await _authRepository.signInAnonymously();

      await _userRepository.createUserIfNotExists(user);

      emit(AuthAuthenticated(user));

    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onGoogleSignIn(
      SignInWithGoogleRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.signInWithGoogle();

      await _userRepository.createUserIfNotExists(user);

      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(
      SignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    await _authRepository.signOut();
    emit(AuthUnauthenticated());
  }
}
