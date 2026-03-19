import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/core/storage/session_storage_keys.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:dio/dio.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final Dio dio;
  final KeyValueStorageService keyValueStorageService;

  AuthDataSourceImpl({required this.dio, required this.keyValueStorageService});

  @override
  Future<User> login(String usuario, String password, String codEntidad) async {
    try {
      final Response<dynamic> response = await dio.post(
        '/app/login',
        data: <String, String>{
          'username': usuario,
          'password': password,
          'codEmp': codEntidad,
        },
        options: Options(extra: <String, bool>{'skipAuth': true}),
      );

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw const AppFailure(
          type: AppFailureType.serverError,
          message: 'Respuesta vacia del servidor.',
        );
      }

      final Map<String, dynamic> data = _extractLoginPayload(response.data);
      final User user = UserMapper.fromLoginPayload(
        data,
        fallbackUsername: usuario,
      );

      if (user.token.isEmpty) {
        throw const AppFailure(
          type: AppFailureType.serverError,
          message: 'Token no recibido del servidor.',
        );
      }

      return user;
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo iniciar sesion.',
        treatUnauthorizedAsInvalidCredentials: true,
        invalidCredentialsMessage: 'Credenciales invalidas.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(e, message: 'No se pudo iniciar sesion.');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    final String? token = await keyValueStorageService.getValue<String>(
      SessionStorageKeys.accessToken,
    );
    final String tokenType =
        await keyValueStorageService.getValue<String>(
          SessionStorageKeys.tokenType,
        ) ??
        'Bearer';

    if (token == null || token.isEmpty) {
      throw const AppFailure(
        type: AppFailureType.sessionExpired,
        message: 'Tu sesion expiro. Inicia sesion nuevamente.',
      );
    }

    try {
      final Response<dynamic> response = await dio.get('/app/me');
      final Map<String, dynamic> data = ResponseContractValidator.expectMap(
        response.data,
        message: 'Respuesta invalida del servidor al consultar /app/me.',
      );
      return UserMapper.fromMePayload(data, token: token, tokenType: tokenType);
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo validar la sesion actual.',
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/app/logout');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return;
      }

      throw DioErrorMapper.map(e, fallbackMessage: 'No se pudo cerrar sesion.');
    }
  }

  Map<String, dynamic> _extractLoginPayload(Map<String, dynamic> json) {
    final dynamic nestedData = json['data'];

    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }

    if (nestedData is Map) {
      return Map<String, dynamic>.from(nestedData);
    }

    return json;
  }
}
