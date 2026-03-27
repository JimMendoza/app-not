import 'package:app_not/core/push/push_token_backend_client.dart';
import 'package:app_not/core/storage/session_storage_keys.dart';
import 'package:app_not/features/auth/presentation/providers/auth_provider.dart';
import 'package:app_not/features/home/presentation/providers/module_provider.dart';
import 'package:app_not/features/notificaciones/domain/domain.dart';
import 'package:app_not/features/notificaciones/presentation/providers/notificaciones_provider.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service_provider.dart';
import 'package:app_not/features/tramites/presentation/providers/tramites_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';
import '../support/test_fakes.dart';

void main() {
  testWidgets('mantiene tabs y contenido alineados al salir de Tema hacia Tramites e Inicio', (
    WidgetTester tester,
  ) async {
    final user = buildCanonicalUser();
    final storage = InMemoryKeyValueStorageService(
      seed: <String, Object?>{
        SessionStorageKeys.accessToken: user.token,
        SessionStorageKeys.tokenType: user.tokenType,
        SessionStorageKeys.rememberSession: '1',
        SessionStorageKeys.dataPolicyAcceptanceKey(user.username):
            SessionStorageKeys.dataPolicyVersion,
      },
    );
    final authRepository = FakeAuthRepository(currentUserResponse: user);
    final moduleRepository = FakeModuleRepository(
      modules: <dynamic>[
        buildModule(
          id: 'mesa_partes_virtual',
          nombre: 'Mesa de Partes Virtual',
          icono: 'description',
        ),
        buildModule(
          id: 'notificaciones',
          nombre: 'Notificaciones',
          icono: 'notifications',
        ),
      ].cast(),
    );
    final notificacionesRepository = FakeNotificacionesRepository(
      resumen: const NotificacionesResumen(noLeidas: 2),
    );
    final tramitesRepository = FakeTramitesRepository(
      tramites: <dynamic>[
        buildTramite(id: 1, siguiendo: false),
      ].cast(),
    );

    final router = await pumpRouterApp(
      tester,
      overrides: [
        keyValueStorageServiceProvider.overrideWith((ref) => storage),
        authRepositoryProvider.overrideWith((ref) => authRepository),
        pushTokenBackendClientProvider.overrideWith(
          (ref) => FakePushTokenBackendClient(),
        ),
        moduleRepositoryProvider.overrideWith((ref) => moduleRepository),
        notificacionesRepositoryProvider.overrideWith(
          (ref) => notificacionesRepository,
        ),
        tramitesRepositoryProvider.overrideWith((ref) => tramitesRepository),
      ],
    );

    await tester.pumpAndSettle();
    expect(find.text('Selecciona un modulo para comenzar'), findsOneWidget);

    router.go('/ajustes/tema');
    await tester.pumpAndSettle();
    expect(find.text('Tema'), findsOneWidget);

    await tester.tap(find.text('Tramites'));
    await tester.pumpAndSettle();
    expect(find.text('Listado de tramites'), findsOneWidget);
    expect(find.text('Tema'), findsNothing);

    await tester.tap(find.text('Inicio'));
    await tester.pumpAndSettle();
    expect(find.text('Selecciona un modulo para comenzar'), findsOneWidget);
    expect(find.text('Tema'), findsNothing);
  });
}
