import 'package:app_not/features/notificaciones/domain/domain.dart';
import 'package:app_not/features/notificaciones/presentation/providers/providers.dart';
import 'package:app_not/features/tramites/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_fakes.dart';

void main() {
  group('Notificaciones providers', () {
    test('carga notificaciones ordenadas por fecha descendente y resumen', () async {
      final FakeNotificacionesRepository repository = FakeNotificacionesRepository(
        notificaciones: <Notificacion>[
          buildNotificacion(
            id: 1,
            tramiteId: 7,
            fechaHora: '2026-03-20T10:00:00',
          ),
          buildNotificacion(
            id: 2,
            tramiteId: 7,
            leida: true,
            fechaHora: '2026-03-22T09:00:00',
          ),
          buildNotificacion(
            id: 3,
            tramiteId: 8,
            fechaHora: '2026-03-21T08:00:00',
          ),
        ],
        resumen: const NotificacionesResumen(noLeidas: 2),
      );
      final FakeTramitesRepository tramitesRepository = FakeTramitesRepository(
        tramites: <dynamic>[
          buildTramite(id: 7, notificacionesNoLeidas: 2),
          buildTramite(id: 8, notificacionesNoLeidas: 1),
        ].cast(),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          notificacionesRepositoryProvider.overrideWith((ref) => repository),
          tramitesRepositoryProvider.overrideWith((ref) => tramitesRepository),
        ],
      );
      addTearDown(container.dispose);

      final notificationsSub = container.listen<NotificacionesState>(
        notificacionesProvider,
        (previous, next) {},
      );
      final tramitesSub = container.listen<TramitesState>(
        tramitesProvider,
        (previous, next) {},
      );
      addTearDown(notificationsSub.close);
      addTearDown(tramitesSub.close);

      await container.read(tramitesProvider.notifier).loadTramites();
      await container.read(notificacionesProvider.notifier).loadNotificaciones();

      final NotificacionesState state = container.read(notificacionesProvider);
      final List<int> orderedIds = state.notificaciones.asData!.value
          .map((notificacion) => notificacion.id)
          .toList(growable: false);

      expect(orderedIds, <int>[2, 3, 1]);
      expect(state.noLeidas, 2);
    });

    test('marcarComoLeida actualiza lista, resumen local y badge por tramite', () async {
      final FakeNotificacionesRepository repository = FakeNotificacionesRepository(
        notificaciones: <Notificacion>[
          buildNotificacion(
            id: 10,
            tramiteId: 7,
            fechaHora: '2026-03-22T11:00:00',
          ),
        ],
        resumen: const NotificacionesResumen(noLeidas: 1),
      );
      final FakeTramitesRepository tramitesRepository = FakeTramitesRepository(
        tramites: <dynamic>[
          buildTramite(id: 7, notificacionesNoLeidas: 3),
        ].cast(),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          notificacionesRepositoryProvider.overrideWith((ref) => repository),
          tramitesRepositoryProvider.overrideWith((ref) => tramitesRepository),
        ],
      );
      addTearDown(container.dispose);

      final notificationsSub = container.listen<NotificacionesState>(
        notificacionesProvider,
        (previous, next) {},
      );
      final tramitesSub = container.listen<TramitesState>(
        tramitesProvider,
        (previous, next) {},
      );
      addTearDown(notificationsSub.close);
      addTearDown(tramitesSub.close);

      await container.read(tramitesProvider.notifier).loadTramites();
      await container.read(notificacionesProvider.notifier).loadNotificaciones();
      final Notificacion notification = container
          .read(notificacionesProvider)
          .notificaciones
          .asData!
          .value
          .single;

      final Object? result = await container
          .read(notificacionesProvider.notifier)
          .marcarComoLeida(notification);

      final NotificacionesState notificationState = container.read(notificacionesProvider);
      final TramitesState tramiteState = container.read(tramitesProvider);

      expect(result, isNull);
      expect(repository.markedAsRead, <int>[10]);
      expect(notificationState.noLeidas, 0);
      expect(notificationState.notificaciones.asData!.value.single.leida, isTrue);
      expect(
        tramiteState.tramites.asData!.value.single.notificacionesNoLeidas,
        2,
      );
    });

    test('oculta badge ui cuando la preferencia mostrarContadorNoLeidas esta apagada', () async {
      final FakeNotificacionesRepository repository = FakeNotificacionesRepository(
        resumen: const NotificacionesResumen(noLeidas: 5),
        configuracion: const NotificacionConfiguracion(
          silenciarFueraDeHorario: false,
          horaSilencioInicio: '22:00',
          horaSilencioFin: '07:00',
          mostrarContadorNoLeidas: false,
        ),
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          notificacionesRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      await container.read(notificacionesBadgeVisiblePreferenceProvider.future);
      final UnreadBadgeUiState uiState = container.read(
        notificacionesUnreadBadgeUiProvider,
      );

      expect(uiState.visible, isFalse);
      expect(uiState.count, 0);
      expect(uiState.hasError, isFalse);
    });
  });
}
