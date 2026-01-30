import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/legacy.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = AuthRepositoryImpl();

  return AuthNotifier(authRepository: authRepository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthNotifier({required this.authRepository}) : super(AuthState());

  Future<User> validarUsuario(String username) async {
    try {
      final user = await authRepository.validarUsuario(username);
      _setUsernameUser(user);
      return user;
    } on CustomError catch (e) {
      logout(e.message);
      rethrow;
    } catch (e) {
      logout('Error no controlado');
      rethrow;
    }
  }

  void _setUsernameUser(User user) {
    state = state.copyWith(username: user.username);
  }

  Future<void> logout([String? errorMessage]) async {
    state = state.copyWith(
      authStatus: AuthStatus.notAuthenticated,
      user: null,
      errorMessage: errorMessage,
    );
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final String username;
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;

  AuthState({
    this.username = '',
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
  });

  AuthState copyWith({
    String? username,
    AuthStatus? authStatus,
    User? user,
    String? errorMessage,
  }) => AuthState(
    username: username ?? this.username,
    authStatus: authStatus ?? this.authStatus,
    user: user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
