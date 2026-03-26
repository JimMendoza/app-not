import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/features/notificaciones/domain/domain.dart';

class NotificacionMapper {
  static const String _invalidNotificacionesMessage =
      'Respuesta invalida del servidor al cargar /app/notificaciones.';

  static Notificacion notificacionJsonToEntity(Map<String, dynamic> json) =>
      Notificacion(
        id: ResponseContractValidator.expectInt(
          json,
          'id',
          message: _invalidNotificacionesMessage,
        ),
        tramiteId: ResponseContractValidator.expectInt(
          json,
          'tramiteId',
          message: _invalidNotificacionesMessage,
        ),
        codigoTramite: ResponseContractValidator.expectString(
          json,
          'codigoTramite',
          message: _invalidNotificacionesMessage,
        ),
        titulo: ResponseContractValidator.expectString(
          json,
          'titulo',
          message: _invalidNotificacionesMessage,
        ),
        mensaje: ResponseContractValidator.expectString(
          json,
          'mensaje',
          message: _invalidNotificacionesMessage,
        ),
        tipo: ResponseContractValidator.expectString(
          json,
          'tipo',
          message: _invalidNotificacionesMessage,
        ),
        leida: ResponseContractValidator.expectBool(
          json,
          'leida',
          message: _invalidNotificacionesMessage,
        ),
        fechaHora: ResponseContractValidator.expectString(
          json,
          'fechaHora',
          message: _invalidNotificacionesMessage,
        ),
      );

  static List<Notificacion> notificacionListJsonToEntity(
    List<dynamic> jsonList,
  ) {
    final List<Map<String, dynamic>> notificaciones =
        ResponseContractValidator.expectMapList(
          jsonList,
          message: _invalidNotificacionesMessage,
        );

    return notificaciones.map(notificacionJsonToEntity).toList(growable: false);
  }
}

