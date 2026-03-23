import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';

class NotificacionConfiguracionMapper {
  static const String _defaultHoraInicio = '22:00';
  static const String _defaultHoraFin = '07:00';
  static const String _defaultZonaHoraria = 'America/Lima';

  static NotificacionConfiguracion jsonToEntity(Map<String, dynamic> json) {
    return NotificacionConfiguracion(
      silenciarFueraDeHorario: _toBool(json['silenciar_fuera_de_horario']),
      horaSilencioInicio: _toHora(
        json['hora_silencio_inicio'],
        fallback: _defaultHoraInicio,
      ),
      horaSilencioFin: _toHora(
        json['hora_silencio_fin'],
        fallback: _defaultHoraFin,
      ),
      mostrarContadorNoLeidas: _toBool(json['mostrar_contador_no_leidas']),
    );
  }

  static Map<String, dynamic> entityToJson(NotificacionConfiguracion entity) {
    return <String, dynamic>{
      'silenciar_fuera_de_horario': entity.silenciarFueraDeHorario,
      'hora_silencio_inicio': entity.horaSilencioInicio,
      'hora_silencio_fin': entity.horaSilencioFin,
      'zona_horaria': _defaultZonaHoraria,
      'mostrar_contador_no_leidas': entity.mostrarContadorNoLeidas,
    };
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      return normalized == '1' ||
          normalized == 'true' ||
          normalized == 'si' ||
          normalized == 'yes' ||
          normalized == 'on';
    }

    return false;
  }

  static String _toHora(dynamic value, {required String fallback}) {
    final String rawValue = value?.toString().trim() ?? '';
    final RegExp hhmmPattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    if (!hhmmPattern.hasMatch(rawValue)) {
      return fallback;
    }

    return rawValue;
  }
}
