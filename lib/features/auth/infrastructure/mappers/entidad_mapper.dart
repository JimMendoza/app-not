import 'package:app_gore_callao/features/auth/domain/domain.dart';

class EntidadMapper {
  static Entidad entidadJsonToEntity(Map<String, dynamic> json) => Entidad(
    id: json['cod_emp']?.toString() ?? json['id']?.toString() ?? '',
    siglas:
        json['abrv'] ?? json['sig'] ?? json['siglas'] ?? json['cod_emp'] ?? '',
    nombre: json['nombre'] ?? json['nom'] ?? '',
    claims: json['claims'],
    imagen: json['imagen'],
  );

  static List<Entidad> entidadListJsonToEntity(List<dynamic> jsonList) {
    return jsonList.map((json) => entidadJsonToEntity(json)).toList();
  }
}
