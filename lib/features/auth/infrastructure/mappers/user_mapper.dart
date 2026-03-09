import 'package:app_gore_callao/features/auth/domain/domain.dart';

class UserMapper {
  static User fromLoginPayload(
    Map<String, dynamic> json, {
    required String fallbackUsername,
    required String codEntidad,
  }) => User(
    username: (json['username'] as String?) ?? fallbackUsername,
    fullName:
        (json['fullName'] as String?) ??
        (json['nombre'] as String?) ??
        fallbackUsername,
    codEntidad: codEntidad,
    permisos: _parsePermisos(json['permisos']),
    token: (json['accessToken'] as String?) ?? '',
    tokenType: (json['tokenType'] as String?) ?? 'Bearer',
  );

  static User fromMePayload(
    Map<String, dynamic> json, {
    required String token,
    required String tokenType,
  }) {
    final Map<String, dynamic>? empresa = json['empresa'] is Map<String, dynamic>
        ? json['empresa'] as Map<String, dynamic>
        : null;

    final String username = (json['username'] as String?) ?? '';

    return User(
      username: username,
      fullName:
          (json['fullName'] as String?) ?? (json['nombre'] as String?) ?? username,
      codEntidad:
          (empresa?['id'] as String?) ??
          (json['codEntidad'] as String?) ??
          (json['codEmp'] as String?) ??
          '',
      permisos: _parsePermisos(json['permisos']),
      token: token,
      tokenType: tokenType,
    );
  }

  static List<String> _parsePermisos(dynamic value) {
    if (value is List<dynamic>) {
      return value.map((dynamic permiso) => permiso.toString()).toList();
    }

    return <String>[];
  }
}
