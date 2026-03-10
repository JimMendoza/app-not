import 'package:app_gore_callao/core/network/app_dio_provider.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:app_gore_callao/features/notificaciones/infrastructure/infrastructure.dart';
import 'package:app_gore_callao/features/tramites/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final Provider<NotificacionesRepository> notificacionesRepositoryProvider =
    Provider<NotificacionesRepository>((ref) {
      return NotificacionesRepositoryImpl(
        dataSource: NotificacionesDataSourceImpl(
          dio: ref.watch(appDioProvider),
        ),
      );
    });

final FutureProvider<int> notificacionesNoLeidasProvider =
    FutureProvider<int>((ref) async {
      final NotificacionesRepository repository = ref.watch(
        notificacionesRepositoryProvider,
      );
      final NotificacionesResumen resumen =
          await repository.getResumenNotificaciones();
      return resumen.noLeidas;
    });

final notificacionesProvider =
    StateNotifierProvider.autoDispose<NotificacionesNotifier, NotificacionesState>((ref) {
  final NotificacionesNotifier notifier = NotificacionesNotifier(
    repository: ref.watch(notificacionesRepositoryProvider),
    ref: ref,
  );
  notifier.loadNotificaciones();
  return notifier;
});

class NotificacionesNotifier extends StateNotifier<NotificacionesState> {
  final NotificacionesRepository repository;
  final Ref ref;

  NotificacionesNotifier({
    required this.repository,
    required this.ref,
  }) : super(const NotificacionesState());

  Future<void> loadNotificaciones() async {
    state = state.copyWith(
      notificaciones: const AsyncValue<List<Notificacion>>.loading(),
      isLoadingResumen: true,
      resumenError: '',
    );

    try {
      final List<Notificacion> notificaciones = await repository
          .getNotificaciones();
      state = state.copyWith(
        notificaciones: AsyncValue<List<Notificacion>>.data(notificaciones),
      );

      try {
        final NotificacionesResumen resumen =
            await repository.getResumenNotificaciones();
        state = state.copyWith(
          noLeidas: resumen.noLeidas,
          isLoadingResumen: false,
          resumenError: '',
        );
      } catch (e) {
        state = state.copyWith(
          noLeidas: _countNoLeidas(notificaciones),
          isLoadingResumen: false,
          resumenError: e.toString(),
        );
      }
    } catch (e, stackTrace) {
      state = state.copyWith(
        notificaciones: AsyncValue<List<Notificacion>>.error(e, stackTrace),
        isLoadingResumen: false,
      );
    } finally {
      ref.invalidate(notificacionesNoLeidasProvider);
    }
  }

  Future<String?> marcarComoLeida(Notificacion notificacion) async {
    final int notificacionId = notificacion.id;

    if (notificacion.leida ||
        state.pendingMarcarLeidaIds.contains(notificacionId)) {
      return null;
    }

    state = state.copyWith(
      pendingMarcarLeidaIds: <int>{...state.pendingMarcarLeidaIds, notificacionId},
    );

    try {
      await repository.marcarComoLeida(notificacionId);
      _updateLocalReadStatus(notificacionId, true);
      ref.invalidate(notificacionesNoLeidasProvider);
      ref.invalidate(tramitesProvider);
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      final Set<int> updatedPending = <int>{...state.pendingMarcarLeidaIds}
        ..remove(notificacionId);
      state = state.copyWith(pendingMarcarLeidaIds: updatedPending);
    }
  }

  void _updateLocalReadStatus(int notificacionId, bool leida) {
    final List<Notificacion>? current = state.notificaciones.asData?.value;
    if (current == null) {
      return;
    }

    final bool wasUnread = current.any(
      (Notificacion n) => n.id == notificacionId && !n.leida,
    );

    final List<Notificacion> updated = current
        .map(
          (Notificacion item) =>
              item.id == notificacionId ? item.copyWith(leida: leida) : item,
        )
        .toList();

    state = state.copyWith(
      notificaciones: AsyncValue<List<Notificacion>>.data(updated),
      noLeidas:
          wasUnread && leida ? _safeDecrement(state.noLeidas) : state.noLeidas,
    );
  }

  int _countNoLeidas(List<Notificacion> notificaciones) {
    return notificaciones.where((Notificacion n) => !n.leida).length;
  }

  int _safeDecrement(int value) {
    return value > 0 ? value - 1 : 0;
  }
}

class NotificacionesState {
  final AsyncValue<List<Notificacion>> notificaciones;
  final int noLeidas;
  final bool isLoadingResumen;
  final String resumenError;
  final Set<int> pendingMarcarLeidaIds;

  const NotificacionesState({
    this.notificaciones = const AsyncValue<List<Notificacion>>.loading(),
    this.noLeidas = 0,
    this.isLoadingResumen = false,
    this.resumenError = '',
    this.pendingMarcarLeidaIds = const <int>{},
  });

  bool isMarcarLeidaPending(int notificacionId) {
    return pendingMarcarLeidaIds.contains(notificacionId);
  }

  NotificacionesState copyWith({
    AsyncValue<List<Notificacion>>? notificaciones,
    int? noLeidas,
    bool? isLoadingResumen,
    String? resumenError,
    Set<int>? pendingMarcarLeidaIds,
  }) => NotificacionesState(
    notificaciones: notificaciones ?? this.notificaciones,
    noLeidas: noLeidas ?? this.noLeidas,
    isLoadingResumen: isLoadingResumen ?? this.isLoadingResumen,
    resumenError: resumenError ?? this.resumenError,
    pendingMarcarLeidaIds:
        pendingMarcarLeidaIds ?? this.pendingMarcarLeidaIds,
  );
}
