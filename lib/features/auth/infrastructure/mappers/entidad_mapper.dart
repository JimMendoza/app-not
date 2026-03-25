import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';

class EntidadMapper {
  static const String _invalidEntidadesMessage =
      'Respuesta invalida del servidor al cargar /app/entidades.';

  static Entidad entidadJsonToEntity(Map<String, dynamic> json) => Entidad(
    id: ResponseContractValidator.expectString(
      json,
      'id',
      message: _invalidEntidadesMessage,
      allowEmpty: false,
    ),
    nombre: ResponseContractValidator.expectString(
      json,
      'nombre',
      message: _invalidEntidadesMessage,
      allowEmpty: false,
    ),
    imagen: _optionalString(json, 'imagen', message: _invalidEntidadesMessage),
  );

  static List<Entidad> entidadListJsonToEntity(List<dynamic> jsonList) {
    final List<Map<String, dynamic>> entidades =
        ResponseContractValidator.expectMapList(
          jsonList,
          message: _invalidEntidadesMessage,
        );

    return entidades.map(entidadJsonToEntity).toList(growable: false);
  }

  static String _optionalString(
    Map<String, dynamic> json,
    String key, {
    required String message,
  }) {
    if (!json.containsKey(key)) {
      throw ResponseContractValidator.invalidResponse(message, cause: json);
    }

    final dynamic value = json[key];
    if (value == null) {
      return '';
    }

    if (value is String) {
      return value.trim();
    }

    throw ResponseContractValidator.invalidResponse(message, cause: value);
  }
}
