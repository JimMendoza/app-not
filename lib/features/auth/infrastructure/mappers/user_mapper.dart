import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';

class UserMapper {
  static const String _invalidMeMessage =
      'Respuesta invalida del servidor al consultar /app/me.';

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
    final Map<String, dynamic> empresa =
        ResponseContractValidator.expectMapField(
          json,
          'empresa',
          message: _invalidMeMessage,
        );

    return User(
      username: ResponseContractValidator.expectString(
        json,
        'username',
        message: _invalidMeMessage,
        allowEmpty: false,
      ),
      fullName: ResponseContractValidator.expectString(
        json,
        'fullName',
        message: _invalidMeMessage,
      ),
      codEntidad: ResponseContractValidator.expectString(
        empresa,
        'id',
        message: _invalidMeMessage,
      ),
      entidadNombre: ResponseContractValidator.expectString(
        empresa,
        'nombre',
        message: _invalidMeMessage,
      ),
      permisos: ResponseContractValidator.expectStringList(
        json,
        'permisos',
        message: _invalidMeMessage,
      ),
      token: token,
      tokenType: tokenType,
    );
  }

  static String _toStringValue(dynamic value) {
    return value?.toString().trim() ?? '';
  }
}
