import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/core/network/app_dio_provider.dart';
import 'package:app_not/features/notificaciones/domain/domain.dart';
import 'package:app_not/features/notificaciones/infrastructure/infrastructure.dart';
import 'package:app_not/features/tramites/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<NotificacionesRepository> notificacionesRepositoryProvider =
    Provider<NotificacionesRepository>((ref) {
      return NotificacionesRepositoryImpl(
        dataSource: NotificacionesDataSourceImpl(
          dio: ref.watch(appDioProvider),
        ),
      );
    });

final FutureProvider<int> notificacionesNoLeidasProvider = FutureProvider<int>((
  ref,
) async {
  final NotificacionesRepository repository = ref.watch(
    notificacionesRepositoryProvider,
  );
  final NotificacionesResumen resumen = await repository
      .getResumenNotificaciones();
  return resumen.noLeidas;
});

final FutureProvider<bool> notificacionesBadgeVisiblePreferenceProvider =
    FutureProvider<bool>((ref) async {
      final NotificacionesRepository repository = ref.watch(
        notificacionesRepositoryProvider,
      );
      final NotificacionConfiguracion configuracion = await repository
          .getConfiguracionNotificaciones();
      return configuracion.mostrarContadorNoLeidas;
    });

final Provider<UnreadBadgeUiState> notificacionesUnreadBadgeUiProvider =
    Provider<UnreadBadgeUiState>((ref) {
      final bool shouldShowBadge = ref
          .watch(notificacionesBadgeVisiblePreferenceProvider)
          .maybeWhen(data: (bool value) => value, orElse: () => true);

      if (!shouldShowBadge) {
        return const UnreadBadgeUiState.hidden();
      }

      final AsyncValue<int> unreadAsync = ref.watch(
        notificacionesNoLeidasProvider,
      );

      return UnreadBadgeUiState(
        visible: true,
        count: unreadAsync.asData?.value ?? 0,
        hasError: unreadAsync.hasError,
      );
    });

final notificacionesProvider =
    NotifierProvider.autoDispose<NotificacionesNotifier, NotificacionesState>(
      NotificacionesNotifier.new,
    );

class NotificacionesNotifier extends Notifier<NotificacionesState> {
  NotificacionesRepository get _repository =>
      ref.read(notificacionesRepositoryProvider);

  @override
  NotificacionesState build() {
    Future<void>.microtask(loadNotificaciones);
    return const NotificacionesState();
  }

  Future<void> loadNotificaciones() async {
    state = state.copyWith(
      notificaciones: const AsyncValue<List<Notificacion>>.loading(),
      isLoadingResumen: true,
      resumenError: '',
    );

    try {
      final List<Notificacion> notificaciones = _sortByFechaDesc(
        await _repository.getNotificaciones(),
      );
      state = state.copyWith(
        notificaciones: AsyncValue<List<Notificacion>>.data(notificaciones),
      );

      try {
        final NotificacionesResumen resumen = await _repository
            .getResumenNotificaciones();
        state = state.copyWith(
          noLeidas: resumen.noLeidas,
          isLoadingResumen: false,
          resumenError: '',
        );
      } catch (e) {
        state = state.copyWith(
          noLeidas: _countNoLeidas(notificaciones),
          isLoadingResumen: false,
          resumenError: AppErrorFormatter.readable(e),
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

  Future<Object?> marcarComoLeida(Notificacion notificacion) async {
    final int notificacionId = notificacion.id;

    if (notificacion.leida ||
        state.pendingMarcarLeidaIds.contains(notificacionId)) {
      return null;
    }

    state = state.copyWith(
      pendingMarcarLeidaIds: <int>{
        ...state.pendingMarcarLeidaIds,
        notificacionId,
      },
    );

    try {
      await _repository.marcarComoLeida(notificacionId);
      _updateLocalReadStatus(notificacionId, true);
      ref
          .read(tramitesProvider.notifier)
          .markNotificationAsReadForTramite(notificacion.tramiteId);
      ref.invalidate(notificacionesNoLeidasProvider);
      return null;
    } catch (e) {
      return e;
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
      noLeidas: wasUnread && leida
          ? _safeDecrement(state.noLeidas)
          : state.noLeidas,
    );
  }

  int _countNoLeidas(List<Notificacion> notificaciones) {
    return notificaciones.where((Notificacion n) => !n.leida).length;
  }

  int _safeDecrement(int value) {
    return value > 0 ? value - 1 : 0;
  }

  List<Notificacion> _sortByFechaDesc(List<Notificacion> notificaciones) {
    final List<Notificacion> ordered = <Notificacion>[...notificaciones];
    ordered.sort(_compareByFechaDesc);
    return ordered;
  }

  int _compareByFechaDesc(Notificacion a, Notificacion b) {
    final DateTime? fechaA = _tryParseFechaHora(a.fechaHora);
    final DateTime? fechaB = _tryParseFechaHora(b.fechaHora);

    if (fechaA != null && fechaB != null) {
      final int byFecha = fechaB.compareTo(fechaA);
      if (byFecha != 0) {
        return byFecha;
      }
    } else if (fechaA != null) {
      return -1;
    } else if (fechaB != null) {
      return 1;
    }

    return b.id.compareTo(a.id);
  }

  DateTime? _tryParseFechaHora(String rawFechaHora) {
    final String normalized = rawFechaHora.trim();
    if (normalized.isEmpty) {
      return null;
    }

    final DateTime? isoDate = DateTime.tryParse(normalized);
    if (isoDate != null) {
      return isoDate;
    }

    final RegExp latinDatePattern = RegExp(
      r'^(\d{2})[/-](\d{2})[/-](\d{4})(?:[ T](\d{2}):(\d{2})(?::(\d{2}))?)?$',
    );
    final RegExpMatch? match = latinDatePattern.firstMatch(normalized);
    if (match == null) {
      return null;
    }

    final int? day = int.tryParse(match.group(1) ?? '');
    final int? month = int.tryParse(match.group(2) ?? '');
    final int? year = int.tryParse(match.group(3) ?? '');
    final int hour = int.tryParse(match.group(4) ?? '') ?? 0;
    final int minute = int.tryParse(match.group(5) ?? '') ?? 0;
    final int second = int.tryParse(match.group(6) ?? '') ?? 0;

    if (day == null || month == null || year == null) {
      return null;
    }

    try {
      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return null;
    }
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
    pendingMarcarLeidaIds: pendingMarcarLeidaIds ?? this.pendingMarcarLeidaIds,
  );
}

class UnreadBadgeUiState {
  final bool visible;
  final int count;
  final bool hasError;

  const UnreadBadgeUiState({
    required this.visible,
    required this.count,
    required this.hasError,
  });

  const UnreadBadgeUiState.hidden()
    : visible = false,
      count = 0,
      hasError = false;
}
