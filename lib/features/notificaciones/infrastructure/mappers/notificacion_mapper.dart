import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';

class NotificacionMapper {
  static Notificacion notificacionJsonToEntity(Map<String, dynamic> json) =>
      Notificacion(
        id: _toInt(json['id']),
        tramiteId: _toInt(json['tramiteId']),
        codigoTramite: (json['codigoTramite']?.toString() ?? '').trim(),
        titulo: (json['titulo']?.toString() ?? '').trim(),
        mensaje: (json['mensaje']?.toString() ?? '').trim(),
        tipo: (json['tipo']?.toString() ?? '').trim(),
        leida: _toBool(json['leida']),
        fechaHora: (json['fechaHora']?.toString() ?? '').trim(),
      );

  static List<Notificacion> notificacionListJsonToEntity(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(notificacionJsonToEntity)
        .toList();
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is String) {
      return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      return normalized == '1' || normalized == 'true' || normalized == 'si';
    }

    if (value is int) {
      return value == 1;
    }

    return false;
  }
}
