import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/features/auth/domain/domain.dart';

class UserMapper {
  static const String _invalidLoginMessage =
      'Respuesta invalida del servidor al iniciar sesion.';
  static const String _invalidMeMessage =
      'Respuesta invalida del servidor al consultar /app/me.';

  static User fromLoginPayload(
    Map<String, dynamic> json, {
    required String fallbackUsername,
  }) {
    return User(
      username: fallbackUsername,
      fullName: '',
      codEntidad: '',
      entidadNombre: '',
      permisos: const <String>[],
      token: ResponseContractValidator.expectString(
        json,
        'accessToken',
        message: _invalidLoginMessage,
        allowEmpty: false,
      ),
      tokenType: ResponseContractValidator.expectString(
        json,
        'tokenType',
        message: _invalidLoginMessage,
        allowEmpty: false,
      ),
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
}

