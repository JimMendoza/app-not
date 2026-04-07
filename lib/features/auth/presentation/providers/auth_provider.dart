import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/core/network/app_dio_provider.dart';
import 'package:app_not/core/push/device_id_service.dart';
import 'package:app_not/core/push/push_token_backend_client.dart';
import 'package:app_not/core/storage/session_storage_keys.dart';
import 'package:app_not/features/auth/domain/domain.dart';
import 'package:app_not/features/auth/infrastructure/infrastructure.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AuthRepository> authRepositoryProvider =
    Provider<AuthRepository>((Ref ref) {
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

final NotifierProvider<AuthNotifier, AuthState> authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  Future<void>? _logoutFuture;

  AuthRepository get _authRepository => ref.read(authRepositoryProvider);

  KeyValueStorageService get _keyValueStorageService =>
      ref.read(keyValueStorageServiceProvider);

  PushTokenBackendClient get _pushTokenBackendClient =>
      ref.read(pushTokenBackendClientProvider);

  @override
  AuthState build() {
    Future<void>.microtask(checkAuthStatus);
    return const AuthState();
  }

  Future<User> login(
    String username,
    String password,
    String codEntidad,
    bool rememberSession,
  ) async {
    final Future<void>? pendingLogout = _logoutFuture;
    if (pendingLogout != null) {
      await pendingLogout;
    }

    if (state.errorMessage.isNotEmpty) {
      state = state.copyWith(errorMessage: '', clearErrorType: true);
    }

    try {
      final String deviceId = await ref
          .read(deviceIdServiceProvider)
          .getOrCreateDeviceId();

      final User loginResponse = await _authRepository.login(
        username,
        password,
        codEntidad,
        deviceId,
      );
      await _persistSession(loginResponse, rememberSession: rememberSession);

      final User canonicalUser = await _authRepository.getCurrentUser();
      await _setAuthenticatedUser(canonicalUser);
      return canonicalUser;
    } on AppFailure catch (e) {
      await _clearSessionStorage();
      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        clearUser: true,
        errorMessage: e.message,
        errorType: e.type,
      );
      rethrow;
    } catch (e) {
      await _clearSessionStorage();
      final AppFailure unknownFailure = DioErrorMapper.unknown(
        e,
        message: 'No se pudo iniciar sesion.',
      );

      state = state.copyWith(
        authStatus: AuthStatus.notAuthenticated,
        clearUser: true,
        errorMessage: unknownFailure.message,
        errorType: unknownFailure.type,
      );
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(
      authStatus: AuthStatus.checking,
      errorMessage: '',
      clearErrorType: true,
    );

    final bool shouldRestoreSession = await _shouldRestoreSession();
    if (!shouldRestoreSession) {
      await _clearSessionStorage();
      state = const AuthState(authStatus: AuthStatus.notAuthenticated);
      return;
    }

    try {
      final User user = await _authRepository.getCurrentUser();
      final bool hasAcceptedDataPolicy = await _hasAcceptedDataPolicyForUser(
        user,
      );

      state = state.copyWith(
        authStatus: AuthStatus.authenticated,
        user: user,
        hasAcceptedDataPolicy: hasAcceptedDataPolicy,
        errorMessage: '',
        clearErrorType: true,
      );
    } on AppFailure catch (e) {
      await _clearSessionStorage();
      state = AuthState(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: e.message,
        errorType: e.type,
      );
    } catch (e) {
      final AppFailure unknownFailure = DioErrorMapper.unknown(
        e,
        message: 'No se pudo validar la sesion actual.',
      );
      await _clearSessionStorage();
      state = AuthState(
        authStatus: AuthStatus.notAuthenticated,
        errorMessage: unknownFailure.message,
        errorType: unknownFailure.type,
      );
    }
  }

  Future<Object?> refreshCurrentUser() async {
    if (state.authStatus != AuthStatus.authenticated) {
      return null;
    }

    try {
      final User user = await _authRepository.getCurrentUser();
      await _setAuthenticatedUser(user);
      return null;
    } on AppFailure catch (e) {
      if (e.isSessionExpired) {
        await logout(e.message, e.type);
        return e;
      }

      state = state.copyWith(errorMessage: e.message, errorType: e.type);
      return e;
    } catch (e) {
      final AppFailure unknownFailure = DioErrorMapper.unknown(
        e,
        message: 'No se pudo actualizar la sesion actual.',
      );
      state = state.copyWith(
        errorMessage: unknownFailure.message,
        errorType: unknownFailure.type,
      );
      return unknownFailure;
    }
  }

  Future<void> logout([String? errorMessage, AppFailureType? errorType]) async {
    final Future<void>? pendingLogout = _logoutFuture;
    if (pendingLogout != null) {
      return pendingLogout;
    }

    final Future<void> logoutTask = _performLogout(errorMessage, errorType);
    _logoutFuture = logoutTask;

    try {
      await logoutTask;
    } finally {
      _logoutFuture = null;
    }
  }

  Future<void> _performLogout(
    String? errorMessage,
    AppFailureType? errorType,
  ) async {
    try {
      final String? deviceId = await _keyValueStorageService.getValue<String>(
        SessionStorageKeys.pushDeviceId,
      );

      if (deviceId != null && deviceId.trim().isNotEmpty) {
        try {
          await _pushTokenBackendClient.invalidatePushToken(deviceId: deviceId);
        } catch (_) {
          // Best effort: continue logout even if explicit push invalidation fails.
        }
      }

      await _authRepository.logout(deviceId: deviceId);
    } catch (_) {
      // Always continue to clear local session.
    }

    await _clearSessionStorage();
    state = AuthState(
      authStatus: AuthStatus.notAuthenticated,
      errorMessage: errorMessage ?? '',
      errorType: errorType,
    );
  }

  void clearErrorMessage() {
    if (state.errorMessage.isEmpty && state.errorType == null) {
      return;
    }

    state = state.copyWith(errorMessage: '', clearErrorType: true);
  }

  Future<void> acceptDataPolicy() async {
    final User? user = state.user;
    if (user == null) {
      return;
    }

    final String key = SessionStorageKeys.dataPolicyAcceptanceKey(
      user.username,
    );

    await _keyValueStorageService.setKeyValue<String>(
      key,
      SessionStorageKeys.dataPolicyVersion,
    );

    state = state.copyWith(hasAcceptedDataPolicy: true);
  }

  Future<void> _persistSession(
    User user, {
    required bool rememberSession,
  }) async {
    await _keyValueStorageService.setKeyValue<String>(
      SessionStorageKeys.rememberSession,
      rememberSession ? '1' : '0',
    );
    await _keyValueStorageService.setKeyValue<String>(
      SessionStorageKeys.accessToken,
      user.token,
    );
    await _keyValueStorageService.setKeyValue<String>(
      SessionStorageKeys.tokenType,
      user.tokenType,
    );
  }

  Future<void> _setAuthenticatedUser(User user) async {
    final bool hasAcceptedDataPolicy = await _hasAcceptedDataPolicyForUser(
      user,
    );

    state = state.copyWith(
      authStatus: AuthStatus.authenticated,
      user: user,
      hasAcceptedDataPolicy: hasAcceptedDataPolicy,
      errorMessage: '',
      clearErrorType: true,
    );
  }

  Future<void> _clearSessionStorage() async {
    await _keyValueStorageService.removeKeys(SessionStorageKeys.authKeys);
  }

  Future<bool> _shouldRestoreSession() async {
    final String? rememberSessionValue = await _keyValueStorageService
        .getValue<String>(SessionStorageKeys.rememberSession);

    if (rememberSessionValue == null || rememberSessionValue.isEmpty) {
      // Backward compatible default: existing sessions continue to restore.
      return true;
    }

    return rememberSessionValue == '1' ||
        rememberSessionValue.toLowerCase() == 'true';
  }

  Future<bool> _hasAcceptedDataPolicyForUser(User user) async {
    final String key = SessionStorageKeys.dataPolicyAcceptanceKey(
      user.username,
    );
    final String? acceptedVersion = await _keyValueStorageService
        .getValue<String>(key);

    return acceptedVersion == SessionStorageKeys.dataPolicyVersion;
  }
}

enum AuthStatus { checking, authenticated, notAuthenticated }

class AuthState {
  final AuthStatus authStatus;
  final User? user;
  final String errorMessage;
  final AppFailureType? errorType;
  final bool hasAcceptedDataPolicy;

  const AuthState({
    this.authStatus = AuthStatus.checking,
    this.user,
    this.errorMessage = '',
    this.errorType,
    this.hasAcceptedDataPolicy = false,
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
    final User? currentUser = user;
    if (currentUser == null) {
      return '';
    }

    if (currentUser.entidadNombre.isNotEmpty) {
      return currentUser.entidadNombre;
    }

    return currentUser.codEntidad;
  }

  List<String> get permisos => user?.permisos ?? const <String>[];

  AuthState copyWith({
    AuthStatus? authStatus,
    User? user,
    bool clearUser = false,
    String? errorMessage,
    AppFailureType? errorType,
    bool clearErrorType = false,
    bool? hasAcceptedDataPolicy,
  }) => AuthState(
    authStatus: authStatus ?? this.authStatus,
    user: clearUser ? null : user ?? this.user,
    errorMessage: errorMessage ?? this.errorMessage,
    errorType: clearErrorType ? null : errorType ?? this.errorType,
    hasAcceptedDataPolicy: hasAcceptedDataPolicy ?? this.hasAcceptedDataPolicy,
  );
}
