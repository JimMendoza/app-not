import 'package:app_gore_callao/core/network/app_dio_provider.dart';
import 'package:app_gore_callao/features/tramites/domain/domain.dart';
import 'package:app_gore_callao/features/tramites/infrastructure/infrastructure.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final Provider<TramitesRepository> tramitesRepositoryProvider =
    Provider<TramitesRepository>((ref) {
      return TramitesRepositoryImpl(
        dataSource: TramitesDataSourceImpl(
          dio: ref.watch(appDioProvider),
        ),
      );
    });

final StateNotifierProvider<TramitesNotifier, TramitesState> tramitesProvider =
    StateNotifierProvider<TramitesNotifier, TramitesState>((ref) {
      final TramitesNotifier notifier = TramitesNotifier(
        repository: ref.watch(tramitesRepositoryProvider),
      );
      notifier.loadTramites();
      return notifier;
    });

final tramiteHojaRutaProvider =
    FutureProvider.family<List<TramiteMovimiento>, int>((ref, tramiteId) async {
      final TramitesRepository repository = ref.watch(tramitesRepositoryProvider);
      return repository.getHojaRuta(tramiteId);
    });

class TramitesNotifier extends StateNotifier<TramitesState> {
  final TramitesRepository repository;

  TramitesNotifier({required this.repository}) : super(const TramitesState());

  Future<void> loadTramites() async {
    state = state.copyWith(tramites: const AsyncValue<List<Tramite>>.loading());

    try {
      final List<Tramite> tramites = await repository.getTramites();
      state = state.copyWith(
        tramites: AsyncValue<List<Tramite>>.data(tramites),
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        tramites: AsyncValue<List<Tramite>>.error(e, stackTrace),
      );
    }
  }

  Future<String?> toggleSeguimiento(Tramite tramite) async {
    final int tramiteId = tramite.id;
    if (state.pendingSeguimientoIds.contains(tramiteId)) {
      return null;
    }

    state = state.copyWith(
      pendingSeguimientoIds: <int>{...state.pendingSeguimientoIds, tramiteId},
    );

    try {
      if (tramite.siguiendo) {
        await repository.dejarDeSeguirTramite(tramiteId);
      } else {
        await repository.seguirTramite(tramiteId);
      }

      _updateLocalSeguimiento(tramiteId, !tramite.siguiendo);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      final Set<int> updatedPending = <int>{...state.pendingSeguimientoIds}
        ..remove(tramiteId);
      state = state.copyWith(pendingSeguimientoIds: updatedPending);
    }
  }

  void _updateLocalSeguimiento(int tramiteId, bool siguiendo) {
    final List<Tramite>? current = state.tramites.asData?.value;
    if (current == null) {
      return;
    }

    final List<Tramite> updated = current
        .map(
          (Tramite item) => item.id == tramiteId
              ? item.copyWith(siguiendo: siguiendo)
              : item,
        )
        .toList();

    state = state.copyWith(tramites: AsyncValue<List<Tramite>>.data(updated));
  }
}

class TramitesState {
  final AsyncValue<List<Tramite>> tramites;
  final Set<int> pendingSeguimientoIds;

  const TramitesState({
    this.tramites = const AsyncValue<List<Tramite>>.loading(),
    this.pendingSeguimientoIds = const <int>{},
  });

  bool isSeguimientoPending(int tramiteId) {
    return pendingSeguimientoIds.contains(tramiteId);
  }

  TramitesState copyWith({
    AsyncValue<List<Tramite>>? tramites,
    Set<int>? pendingSeguimientoIds,
  }) => TramitesState(
    tramites: tramites ?? this.tramites,
    pendingSeguimientoIds:
        pendingSeguimientoIds ?? this.pendingSeguimientoIds,
  );
}
