import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';

class NotificacionesResumenMapper {
  static NotificacionesResumen resumenJsonToEntity(Map<String, dynamic> json) =>
      NotificacionesResumen(
        noLeidas: _toInt(json['noLeidas']),
      );

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}
