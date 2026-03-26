import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/features/notificaciones/domain/domain.dart';
import 'package:app_not/features/notificaciones/presentation/providers/notificaciones_provider.dart';
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
            ref: ref,
          );
      notifier.loadConfiguracion();
      return notifier;
    });

class NotificacionConfiguracionNotifier
    extends StateNotifier<NotificacionConfiguracionState> {
  final NotificacionesRepository repository;
  final Ref ref;

  NotificacionConfiguracionNotifier({
    required this.repository,
    required this.ref,
  }) : super(const NotificacionConfiguracionState());

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

  void setSilenciarFueraDeHorario(bool enabled) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(silenciarFueraDeHorario: enabled);
    });
  }

  void setHoraSilencioInicio(String hora) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(horaSilencioInicio: hora.trim());
    });
  }

  void setHoraSilencioFin(String hora) {
    _update((NotificacionConfiguracion current) {
      return current.copyWith(horaSilencioFin: hora.trim());
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

    final String? validationError = _validateConfiguracion(configuracion);
    if (validationError != null) {
      state = state.copyWith(
        isSaving: false,
        saveError: validationError,
        saveSuccessMessage: '',
      );
      return AppFailure(
        type: AppFailureType.validationError,
        message: validationError,
      );
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
      ref.invalidate(notificacionesBadgeVisiblePreferenceProvider);
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

  String? _validateConfiguracion(NotificacionConfiguracion configuracion) {
    if (!_isHoraValida(configuracion.horaSilencioInicio)) {
      return 'La hora de inicio no tiene formato valido (HH:mm).';
    }

    if (!_isHoraValida(configuracion.horaSilencioFin)) {
      return 'La hora de fin no tiene formato valido (HH:mm).';
    }

    if (!configuracion.silenciarFueraDeHorario) {
      return null;
    }

    final int inicio = _toMinutes(configuracion.horaSilencioInicio);
    final int fin = _toMinutes(configuracion.horaSilencioFin);
    if (inicio == fin) {
      return 'La hora de inicio y fin no pueden ser iguales.';
    }

    return null;
  }

  bool _isHoraValida(String hora) {
    final RegExp hhmmPattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    return hhmmPattern.hasMatch(hora.trim());
  }

  int _toMinutes(String hhmm) {
    final List<String> parts = hhmm.split(':');
    final int hour = int.tryParse(parts[0]) ?? 0;
    final int minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
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

