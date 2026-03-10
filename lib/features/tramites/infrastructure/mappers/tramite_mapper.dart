import 'package:app_gore_callao/features/tramites/domain/domain.dart';

class TramiteMapper {
  static Tramite tramiteJsonToEntity(Map<String, dynamic> json) => Tramite(
    id: _toInt(json['id']),
    codigo: (json['codigo']?.toString() ?? '').trim(),
    titulo: (json['titulo']?.toString() ?? '').trim(),
    fecha: (json['fecha']?.toString() ?? '').trim(),
    estadoActual: (json['estadoActual']?.toString() ?? '').trim(),
    siguiendo: _toBool(json['siguiendo']),
    notificacionesNoLeidas: _toInt(json['notificacionesNoLeidas']),
  );

  static List<Tramite> tramiteListJsonToEntity(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(tramiteJsonToEntity)
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
