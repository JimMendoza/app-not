import 'package:app_gore_callao/features/auth/domain/domain.dart';

class EntidadMapper {
  static Entidad entidadJsonToEntity(Map<String, dynamic> json) =>
      Entidad(
        id: json['id']?.toString() ?? '',
        nombre: json['nombre']?.toString() ?? '',
        imagen: json['imagen']?.toString() ?? '',
      );

  static List<Entidad> entidadListJsonToEntity(List<dynamic> jsonList) {
    return jsonList.map((json) => entidadJsonToEntity(json)).toList();
  }
}
