import 'package:app_not/core/push/push_token_backend_client.dart';
import 'package:app_not/core/storage/session_storage_keys.dart';
import 'package:app_not/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_fakes.dart';

void main() {
  group('AuthNotifier', () {
    test(
      'login persiste token y devuelve usuario canonico de /app/me',
      () async {
        final loginUser = buildLoginUser();
        final canonicalUser = buildCanonicalUser(token: loginUser.token);
        final FakeAuthRepository repository = FakeAuthRepository(
          loginResponse: loginUser,
          currentUserResponse: canonicalUser,
        );
        final InMemoryKeyValueStorageService storage =
            InMemoryKeyValueStorageService(
              seed: <String, Object?>{SessionStorageKeys.rememberSession: '0'},
            );
        final FakePushTokenBackendClient pushClient =
            FakePushTokenBackendClient();

        final ProviderContainer container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => repository),
            keyValueStorageServiceProvider.overrideWith((ref) => storage),
            pushTokenBackendClientProvider.overrideWith((ref) => pushClient),
          ],
        );
        addTearDown(container.dispose);

        final authSub = container.listen<AuthState>(
          authProvider,
          (previous, next) {},
        );
        addTearDown(authSub.close);
        await Future<void>.delayed(Duration.zero);

        final AuthNotifier notifier = container.read(authProvider.notifier);
        final result = await notifier.login(
          canonicalUser.username,
          '123456',
          canonicalUser.codEntidad,
          true,
        );

        expect(result.fullName, canonicalUser.fullName);
        expect(repository.lastUsername, canonicalUser.username);
        expect(repository.lastCodEntidad, canonicalUser.codEntidad);
        expect(repository.lastLoginDeviceId, isNotNull);
        expect(repository.lastLoginDeviceId, isNotEmpty);
        expect(
          storage.snapshot[SessionStorageKeys.pushDeviceId],
          repository.lastLoginDeviceId,
        );
        expect(
          storage.snapshot[SessionStorageKeys.accessToken],
          loginUser.token,
        );
        expect(
          storage.snapshot[SessionStorageKeys.tokenType],
          loginUser.tokenType,
        );
        expect(storage.snapshot[SessionStorageKeys.rememberSession], '1');
        expect(
          container.read(authProvider).authStatus,
          AuthStatus.authenticated,
        );
        expect(
          container.read(authProvider).user?.entidadNombre,
          canonicalUser.entidadNombre,
        );
      },
    );

    test(
      'checkAuthStatus restaura sesion autenticada y consentimiento',
      () async {
        final canonicalUser = buildCanonicalUser();
        final FakeAuthRepository repository = FakeAuthRepository(
          currentUserResponse: canonicalUser,
        );
        final InMemoryKeyValueStorageService storage =
            InMemoryKeyValueStorageService(
              seed: <String, Object?>{
                SessionStorageKeys.accessToken: canonicalUser.token,
                SessionStorageKeys.tokenType: canonicalUser.tokenType,
                SessionStorageKeys.rememberSession: '1',
                SessionStorageKeys.dataPolicyAcceptanceKey(
                  canonicalUser.username,
                ): SessionStorageKeys.dataPolicyVersion,
              },
            );

        final ProviderContainer container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => repository),
            keyValueStorageServiceProvider.overrideWith((ref) => storage),
            pushTokenBackendClientProvider.overrideWith(
              (ref) => FakePushTokenBackendClient(),
            ),
          ],
        );
        addTearDown(container.dispose);

        final authSub = container.listen<AuthState>(
          authProvider,
          (previous, next) {},
        );
        addTearDown(authSub.close);
        await Future<void>.delayed(Duration.zero);

        final AuthState state = container.read(authProvider);
        expect(state.authStatus, AuthStatus.authenticated);
        expect(state.user?.username, canonicalUser.username);
        expect(state.hasAcceptedDataPolicy, isTrue);
        expect(state.errorMessage, isEmpty);
      },
    );

    test(
      'logout limpia sesion local e invalida deviceId push si existe',
      () async {
        final canonicalUser = buildCanonicalUser();
        final FakeAuthRepository repository = FakeAuthRepository(
          currentUserResponse: canonicalUser,
        );
        final InMemoryKeyValueStorageService storage =
            InMemoryKeyValueStorageService(
              seed: <String, Object?>{
                SessionStorageKeys.accessToken: canonicalUser.token,
                SessionStorageKeys.tokenType: canonicalUser.tokenType,
                SessionStorageKeys.rememberSession: '1',
                SessionStorageKeys.pushDeviceId: 'android-test-001',
              },
            );
        final FakePushTokenBackendClient pushClient =
            FakePushTokenBackendClient();

        final ProviderContainer container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWith((ref) => repository),
            keyValueStorageServiceProvider.overrideWith((ref) => storage),
            pushTokenBackendClientProvider.overrideWith((ref) => pushClient),
          ],
        );
        addTearDown(container.dispose);

        final authSub = container.listen<AuthState>(
          authProvider,
          (previous, next) {},
        );
        addTearDown(authSub.close);
        await Future<void>.delayed(Duration.zero);

        await container.read(authProvider.notifier).logout();

        expect(
          container.read(authProvider).authStatus,
          AuthStatus.notAuthenticated,
        );
        expect(
          storage.snapshot.containsKey(SessionStorageKeys.accessToken),
          isFalse,
        );
        expect(
          storage.snapshot.containsKey(SessionStorageKeys.tokenType),
          isFalse,
        );
        expect(repository.lastLogoutDeviceId, 'android-test-001');
        expect(pushClient.invalidatedDeviceIds, <String>['android-test-001']);
      },
    );
  });
}
