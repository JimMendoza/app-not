import 'package:dio/dio.dart';
import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));

  @override
  Future<User> login(String usuario, String password, String codEntidad) async {
    try {
      print('''
CodEntidad: $codEntidad
Username: $usuario
Password: $password
''');

      final response = await dio.post(
        '/app/login',
        data: {'username': usuario, 'password': password, 'codEmp': codEntidad},
      );

      if (response.data == null) {
        throw CustomError('Respuesta vacía del servidor');
      }

      final accessToken = response.data['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw CustomError('Token no recibido del servidor');
      }

      final token = Token(accessToken: accessToken);
      final user = User(
        username: (response.data['username'] as String?) ?? usuario,
        fullName:
            (response.data['fullName'] as String?) ??
            (response.data['nombre'] as String?) ??
            usuario,
        codEntidad: codEntidad,
        permisos: List<String>.from(response.data['permisos'] as List? ?? []),
        token: accessToken,
      );

      print('Token recibido: ${token.accessToken}');
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw CustomError(
          e.response?.data['mensaje'] ?? 'El usuario no existe.',
        );
      }
      if (e.response?.statusCode == 401) {
        throw CustomError(
          e.response?.data['mensaje'] ?? 'La contraseña es incorrecta.',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      print(e.message);
      throw CustomError(e.response?.data['mensaje'] ?? 'Error: ${e.message}');
    } catch (e) {
      throw CustomError('Error no controlado: ${e.toString()}');
    }
  }
}
