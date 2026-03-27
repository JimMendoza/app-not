import 'package:app_not/features/tramites/domain/domain.dart';
import 'package:app_not/features/tramites/presentation/providers/tramites_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_fakes.dart';

void main() {
  group('TramitesNotifier', () {
    test('seguir tramite actualiza estado local y registra llamada al repositorio', () async {
      final FakeTramitesRepository repository = FakeTramitesRepository(
        tramites: <Tramite>[
          buildTramite(id: 1, siguiendo: false, notificacionesNoLeidas: 2),
        ],
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          tramitesRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final tramitesSub = container.listen<TramitesState>(
        tramitesProvider,
        (previous, next) {},
      );
      addTearDown(tramitesSub.close);

      await container.read(tramitesProvider.notifier).loadTramites();
      final Tramite tramite = container.read(tramitesProvider).tramites.asData!.value.single;
      await container.read(tramitesProvider.notifier).toggleSeguimiento(tramite);

      final Tramite updated = container.read(tramitesProvider).tramites.asData!.value.single;
      expect(repository.seguidos, <int>[1]);
      expect(updated.siguiendo, isTrue);
    });

    test('dejar de seguir tramite actualiza estado local y registra llamada al repositorio', () async {
      final FakeTramitesRepository repository = FakeTramitesRepository(
        tramites: <Tramite>[
          buildTramite(id: 2, siguiendo: true, notificacionesNoLeidas: 1),
        ],
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          tramitesRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final tramitesSub = container.listen<TramitesState>(
        tramitesProvider,
        (previous, next) {},
      );
      addTearDown(tramitesSub.close);

      await container.read(tramitesProvider.notifier).loadTramites();
      final Tramite tramite = container.read(tramitesProvider).tramites.asData!.value.single;
      await container.read(tramitesProvider.notifier).toggleSeguimiento(tramite);

      final Tramite updated = container.read(tramitesProvider).tramites.asData!.value.single;
      expect(repository.noSeguidos, <int>[2]);
      expect(updated.siguiendo, isFalse);
    });

    test('marcar notificacion leida descuenta badge del tramite sin bajar de cero', () async {
      final FakeTramitesRepository repository = FakeTramitesRepository(
        tramites: <Tramite>[
          buildTramite(id: 7, notificacionesNoLeidas: 1),
          buildTramite(id: 8, notificacionesNoLeidas: 0),
        ],
      );
      final ProviderContainer container = ProviderContainer(
        overrides: [
          tramitesRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      addTearDown(container.dispose);

      final tramitesSub = container.listen<TramitesState>(
        tramitesProvider,
        (previous, next) {},
      );
      addTearDown(tramitesSub.close);

      await container.read(tramitesProvider.notifier).loadTramites();
      container.read(tramitesProvider.notifier).markNotificationAsReadForTramite(7);
      container.read(tramitesProvider.notifier).markNotificationAsReadForTramite(8);

      final List<Tramite> tramites = container.read(tramitesProvider).tramites.asData!.value;
      expect(
        tramites.firstWhere((tramite) => tramite.id == 7).notificacionesNoLeidas,
        0,
      );
      expect(
        tramites.firstWhere((tramite) => tramite.id == 8).notificacionesNoLeidas,
        0,
      );
    });
  });
}
