import 'package:app_gore_callao/features/auth/domain/domain.dart';

class UserMapper {
  static User userJsonToEntity(Map<String, dynamic> json) => User(
    id: json['id'],
    email: json['email'],
    fullName: json['fullName'],
    codEntidad: json['codEntidad'],
    permisos: List<String>.from(json['permisos'].map((permiso) => permiso)),
    token: json['token'],
  );
}
