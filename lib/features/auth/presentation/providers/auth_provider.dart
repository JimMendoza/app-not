import 'package:app_gore_callao/core/network/app_dio_provider.dart';
import 'package:app_gore_callao/core/storage/session_storage_keys.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((
  Ref ref,
) {
  final KeyValueStorageService keyValueStorageService = ref.watch(
    keyValueStorageServiceProvider,
  );

  return AuthRepositoryImpl(
    dataSource: AuthDataSourceImpl(
      dio: ref.watch(appDioProvider),
      keyValueStorageService: keyValueStorageService,
    ),
  );
});

final StateNotifierProvider<AuthNotifier, AuthState> authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
      final AuthRepository authRepository = ref.watch(authRepositoryProvider);
      final KeyValueStorageService keyValueStorageService = ref.watch(
        keyValueStorageServiceProvider,
      );

      final AuthNotifier notifier = AuthNotifier(
        authRepository: authRepository,
        keyValueStorageService: keyValueStorageService,
      );

      notifier.checkAuthStatus();
      return notifier;
    });

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;
  final KeyValueStorageService keyValueStorageService;
  Future<void>? _logoutFuture;

  AuthNotifier({
    required this.authRepository,
    required this.keyValueStorageService,
  }) : super(const AuthState());

  Future<User> login(
    String username,
    String password,
    String codEntidad,
  ) async {
    final Future<void>? pendingLogout = _logoutFuture;
    if (pendingLogout != null) {
      await pendingLogout;
    }

    try {
      final User user = await authRepository.login(username, password, codEntidad);
      await _setLoggedUser(user);
      return user;
    } on CustomError catch (e) {
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        clearUser: true,
        errorMessage: e.message,
      );
      rethrow;
    } catch (e) {
      final String errorMessage = e is Exception
          ? e.toString()
          : 'Error no controlado';

      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        clearUser: true,
        errorMessage: errorMessage,
      );
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(authStatus: AuthStatus.checking, errorMessage: '');

    try {
      final User user = await authRepository.getCurrentUser();
      final String selectedEntityName =
          await keyValueStorageService.getValue<String>(
            SessionStorageKeys.selectedEntityName,
          ) ??
          '';
      final String selectedEntityImage =
          await keyValueStorageService.getValue<String>(
            SessionStorageKeys.selectedEntityImage,
          ) ??
          '';

      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
        user: user,
        selectedEntityName: selectedEntityName,
        selectedEntityImage: selectedEntityImage,
        errorMessage: '',
      );
    } on InvalidToken {
      await _clearSessionStorage();
      state = const AuthState(authStatus: AuthStatus.notAuthenticated);
    } on CustomError catch (e) {
      await _clearSessionStorage();
      state = AuthState(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: e.message,
      );
    } catch (_) {
      await _clearSessionStorage();
      state = const AuthState(authStatus: AuthStatus.notAuthenticated);
    }
  }

  Future<void> logout([String? errorMessage]) async {
    final Future<void>? pendingLogout = _logoutFuture;
    if (pendingLogout != null) {
      return pendingLogout;
    }

    final Future<void> logoutTask = _performLogout(errorMessage);
    _logoutFuture = logoutTask;

    try {
      await logoutTask;
    } finally {
      _logoutFuture = null;
    }
  }

  Future<void> _performLogout(String? errorMessage) async {
    try {
      await authRepository.logout();
    } catch (_) {
      // Always continue to clear local session.
    }

    await _clearSessionStorage();
    state = AuthState(
      authStatus: AuthStatus.notAuthenticated,
      errorMessage: errorMessage ?? '',
    );
  }

  void setSelectedEntity({
    required String codEntidad,
    required String entityName,
    required String entityImage,
  }) {
    final User? currentUser = state.user;
    final User? updatedUser = currentUser?.copyWith(codEntidad: codEntidad);

    state = state.copyWith(
      user: updatedUser,
      selectedEntityName: entityName,
      selectedEntityImage: entityImage,
    );
  }

  Future<void> _setLoggedUser(User user) async {
    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: user,
      errorMessage: '',
    );

    await keyValueStorageService.setKeyValue<String>(
      SessionStorageKeys.accessToken,
      user.token,
    );
    await keyValueStorageService.setKeyValue<String>(
      SessionStorageKeys.tokenType,
      user.tokenType,
    );

    if (state.selectedEntityName.isNotEmpty) {
      await keyValueStorageService.setKeyValue<String>(
        SessionStorageKeys.selectedEntityName,
        state.selectedEntityName,
      );
    }

    if (state.selectedEntityImage.isNotEmpty) {
      await keyValueStorageService.setKeyValue<String>(
        SessionStorageKeys.selectedEntityImage,
        state.selectedEntityImage,
      );
    }
  }

  Future<void> _clearSessionStorage() async {
    await keyValueStorageService.removeKeys(SessionStorageKeys.authKeys);
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;
  final String selectedEntityName;
  final String selectedEntityImage;

  const AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
    this.selectedEntityName = '',
    this.selectedEntityImage = '',
  });

  bool get isAuthenticated =>
      authStatus == AuthStatus.authenticated && user != null;

  String get displayName {
    final User? currentUser = user;
    if (currentUser == null) {
      return '';
    }

    return currentUser.fullName.isNotEmpty
        ? currentUser.fullName
        : currentUser.username;
  }

  String get displayEntity {
    if (selectedEntityName.isNotEmpty) {
      return selectedEntityName;
    }

    return user?.codEntidad ?? '';
  }

  List<String> get permisos => user?.permisos ?? const <String>[];

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    String? selectedEntityName,
    String? selectedEntityImage,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: clearUser ? null : user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
    selectedEntityName: selectedEntityName ?? this.selectedEntityName,
    selectedEntityImage: selectedEntityImage ?? this.selectedEntityImage,
  );
}
