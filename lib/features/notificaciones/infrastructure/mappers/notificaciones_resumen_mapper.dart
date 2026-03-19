import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';

class NotificacionesResumenMapper {
  static const String _invalidResumenMessage =
      'Respuesta invalida del servidor al cargar /app/notificaciones/resumen.';

  static NotificacionesResumen resumenJsonToEntity(Map<String, dynamic> json) =>
      NotificacionesResumen(
        noLeidas: ResponseContractValidator.expectInt(
          json,
          'noLeidas',
          message: _invalidResumenMessage,
        ),
      );
}
