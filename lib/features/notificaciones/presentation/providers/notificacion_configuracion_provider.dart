import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/notificaciones_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final notificacionConfiguracionProvider =
    StateNotifierProvider.autoDispose<
      NotificacionConfiguracionNotifier,
      NotificacionConfiguracionState
    >((ref) {
      final NotificacionConfiguracionNotifier notifier =
          NotificacionConfiguracionNotifier(
            repository: ref.watch(notificacionesRepositoryProvider),
          );
      notifier.loadConfiguracion();
      return notifier;
    });

class NotificacionConfiguracionNotifier
    extends StateNotifier<NotificacionConfiguracionState> {
  final NotificacionesRepository repository;

  NotificacionConfiguracionNotifier({required this.repository})
    : super(const NotificacionConfiguracionState());

  Future<void> loadConfiguracion() async {
    state = state.copyWith(
      configuracion: const AsyncValue<NotificacionConfiguracion>.loading(),
      isSaving: false,
      saveError: '',
      saveSuccessMessage: '',
    );

    try {
      final NotificacionConfiguracion configuracion = await repository
          .getConfiguracionNotificaciones();
      state = state.copyWith(
        configuracion: AsyncValue<NotificacionConfiguracion>.data(
          configuracion,
        ),
        originalConfiguracion: configuracion,
      );
    } catch (e, stackTrace) {
      state = state.copyWith(
        configuracion: AsyncValue<NotificacionConfiguracion>.error(
          e,
          stackTrace,
        ),
      );
    }
  }

  void setSoloTramitesSeguidos(bool enabled) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(soloTramitesSeguidos: enabled);
    });
  }

  void setNotificarCambiosEstado(bool enabled) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(notificarCambiosEstado: enabled);
    });
  }

  void setNotificarMovimientosHojaRuta(bool enabled) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(notificarMovimientosHojaRuta: enabled);
    });
  }

  void setSoloEventosImportantes(bool enabled) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(soloEventosImportantes: enabled);
    });
  }

  void setFrecuenciaNotificacion(FrecuenciaNotificacion frecuencia) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(frecuenciaNotificacion: frecuencia);
    });
  }

  void setSilenciarFueraDeHorario(bool enabled) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(silenciarFueraDeHorario: enabled);
    });
  }

  void setMostrarContadorNoLeidas(bool enabled) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(mostrarContadorNoLeidas: enabled);
    });
  }

  Future<Object?> saveConfiguracion() async {
    if (state.isSaving) {
      return null;
    }

    final NotificacionConfiguracion? configuracion =
        state.configuracion.asData?.value;
    if (configuracion == null) {
      return null;
    }

    state = state.copyWith(
      isSaving: true,
      saveError: '',
      saveSuccessMessage: '',
    );

    try {
      await repository.guardarConfiguracionNotificaciones(configuracion);
      state = state.copyWith(
        isSaving: false,
        originalConfiguracion: configuracion,
        saveSuccessMessage: 'Configuracion de notificaciones guardada.',
      );
      return null;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: AppErrorFormatter.readable(e),
        saveSuccessMessage: '',
      );
      return e;
    }
  }

  void clearSaveFeedback() {
    if (state.saveError.isEmpty && state.saveSuccessMessage.isEmpty) {
      return;
    }

    state = state.copyWith(saveError: '', saveSuccessMessage: '');
  }

  void _update(
    NotificacionConfiguracion Function(NotificacionConfiguracion current)
    updater,
  ) {
    final NotificacionConfiguracion? current =
        state.configuracion.asData?.value;
    if (current == null) {
      return;
    }

    final NotificacionConfiguracion updated = updater(current);
    state = state.copyWith(
      configuracion: AsyncValue<NotificacionConfiguracion>.data(updated),
      saveError: '',
      saveSuccessMessage: '',
    );
  }
}

class NotificacionConfiguracionState {
  final AsyncValue<NotificacionConfiguracion> configuracion;
  final NotificacionConfiguracion? originalConfiguracion;
  final bool isSaving;
  final String saveError;
  final String saveSuccessMessage;

  const NotificacionConfiguracionState({
    this.configuracion = const AsyncValue<NotificacionConfiguracion>.loading(),
    this.originalConfiguracion,
    this.isSaving = false,
    this.saveError = '',
    this.saveSuccessMessage = '',
  });

  bool get hasChanges {
    final NotificacionConfiguracion? current = configuracion.asData?.value;
    if (current == null || originalConfiguracion == null) {
      return false;
    }

    return !current.hasSameValues(originalConfiguracion!);
  }

  NotificacionConfiguracionState copyWith({
    AsyncValue<NotificacionConfiguracion>? configuracion,
    NotificacionConfiguracion? originalConfiguracion,
    bool? isSaving,
    String? saveError,
    String? saveSuccessMessage,
  }) => NotificacionConfiguracionState(
    configuracion: configuracion ?? this.configuracion,
    originalConfiguracion: originalConfiguracion ?? this.originalConfiguracion,
    isSaving: isSaving ?? this.isSaving,
    saveError: saveError ?? this.saveError,
    saveSuccessMessage: saveSuccessMessage ?? this.saveSuccessMessage,
  );
}
