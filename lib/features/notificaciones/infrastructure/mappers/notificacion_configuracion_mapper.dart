import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';

class NotificacionConfiguracionMapper {
  static const String _defaultZonaHoraria = 'America/Lima';
  static const String _invalidConfiguracionMessage =
      'Respuesta invalida del servidor al cargar /app/notificaciones/configuracion.';

  static NotificacionConfiguracion jsonToEntity(Map<String, dynamic> json) {
    final String horaInicio = _validateHora(
      ResponseContractValidator.expectString(
        json,
        'hora_silencio_inicio',
        message: _invalidConfiguracionMessage,
        allowEmpty: false,
      ),
      field: 'hora_silencio_inicio',
    );
    final String horaFin = _validateHora(
      ResponseContractValidator.expectString(
        json,
        'hora_silencio_fin',
        message: _invalidConfiguracionMessage,
        allowEmpty: false,
      ),
      field: 'hora_silencio_fin',
    );

    return NotificacionConfiguracion(
      silenciarFueraDeHorario: ResponseContractValidator.expectBool(
        json,
        'silenciar_fuera_de_horario',
        message: _invalidConfiguracionMessage,
      ),
      horaSilencioInicio: horaInicio,
      horaSilencioFin: horaFin,
      mostrarContadorNoLeidas: ResponseContractValidator.expectBool(
        json,
        'mostrar_contador_no_leidas',
        message: _invalidConfiguracionMessage,
      ),
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

  static String _validateHora(String value, {required String field}) {
    final String rawValue = value.trim();
    final RegExp hhmmPattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    if (!hhmmPattern.hasMatch(rawValue)) {
      throw ResponseContractValidator.invalidResponse(
        '$_invalidConfiguracionMessage Campo $field invalido.',
        cause: value,
      );
    }

    return rawValue;
  }
}
