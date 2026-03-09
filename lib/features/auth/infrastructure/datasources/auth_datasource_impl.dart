import 'package:app_gore_callao/core/storage/session_storage_keys.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';
import 'package:app_gore_callao/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:dio/dio.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final Dio dio;
  final KeyValueStorageService keyValueStorageService;

  AuthDataSourceImpl({
    required this.dio,
    required this.keyValueStorageService,
  });

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
        throw CustomError('Respuesta vacia del servidor');
      }

      final Map<String, dynamic> data = _extractPayload(response.data);
      final User user = UserMapper.fromLoginPayload(
        data,
        fallbackUsername: usuario,
        codEntidad: codEntidad,
      );

      if (user.token.isEmpty) {
        throw CustomError('Token no recibido del servidor');
      }

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw CustomError(e.response?.data['mensaje'] ?? 'El usuario no existe.');
      }

      if (e.response?.statusCode == 401) {
        throw CustomError(
          e.response?.data['mensaje'] ?? 'La contrasena es incorrecta.',
        );
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexion a internet');
      }

      throw CustomError(e.response?.data['mensaje'] ?? 'Error: ${e.message}');
    } catch (e) {
      throw CustomError('Error no controlado: ${e.toString()}');
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
      throw InvalidToken();
    }

    try {
      final Response<dynamic> response = await dio.get('/app/me');

      if (response.data == null || response.data is! Map<String, dynamic>) {
        throw CustomError('Respuesta invalida al consultar sesion');
      }

      final Map<String, dynamic> data = _extractPayload(response.data);

      return UserMapper.fromMePayload(
        data,
        token: token,
        tokenType: tokenType,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw InvalidToken();
      }

      throw CustomError(
        e.response?.data?['mensaje'] ?? 'No se pudo validar la sesion actual',
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

      throw CustomError(e.response?.data?['mensaje'] ?? 'No se pudo cerrar sesion');
    }
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> json) {
    final dynamic nestedData = json['data'];

    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }

    return json;
  }
}
