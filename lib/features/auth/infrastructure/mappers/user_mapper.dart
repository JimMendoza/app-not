import 'package:app_gore_callao/features/auth/domain/domain.dart';

class UserMapper {
  static User fromLoginPayload(
    Map<String, dynamic> json, {
    required String fallbackUsername,
  }) {
    final String tokenType =
        _toStringValue(json['tokenType'] ?? json['token_type']) == ''
        ? 'Bearer'
        : _toStringValue(json['tokenType'] ?? json['token_type']);

    return User(
      username: fallbackUsername,
      fullName: '',
      codEntidad: '',
      entidadNombre: '',
      permisos: const <String>[],
      token: _toStringValue(json['accessToken'] ?? json['access_token']),
      tokenType: tokenType,
    );
  }

  static User fromMePayload(
    Map<String, dynamic> json, {
    required String token,
    required String tokenType,
  }) {
    final Map<String, dynamic>? empresa =
        json['empresa'] is Map<String, dynamic>
        ? json['empresa'] as Map<String, dynamic>
        : null;

    final String username = _toStringValue(json['username']);

    return User(
      username: username,
      fullName: _toStringValue(json['fullName'] ?? json['nombre']),
      codEntidad: _toStringValue(
        empresa?['id'] ?? json['codEntidad'] ?? json['codEmp'],
      ),
      entidadNombre: _toStringValue(
        empresa?['nombre'] ??
            json['entidadNombre'] ??
            json['nomEntidad'] ??
            json['empresaNombre'],
      ),
      permisos: _parsePermisos(json['permisos']),
      token: token,
      tokenType: tokenType,
    );
  }

  static List<String> _parsePermisos(dynamic value) {
    if (value is List<dynamic>) {
      return value
          .map((dynamic permiso) => permiso.toString().trim())
          .where((String permiso) => permiso.isNotEmpty)
          .toList();
    }

    return <String>[];
  }

  static String _toStringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
