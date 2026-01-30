import 'package:dio/dio.dart';
import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';

class AuthDataSourceImpl extends AuthDataSource {
  final dio = Dio(BaseOptions(baseUrl: Environment.apiUrl));

  @override
  Future<User> validarUsuario(String usuario) async {
    try {
      final response = await dio.post(
        '/seguridad/auth/validUsuario',
        data: {'usuario': usuario},
      );

      final user = UserMapper.userJsonToEntity(response.data);
      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw CustomError(
          e.response?.data['message'] ?? 'Campos requeridos incompletos',
        );
      }
      if (e.response?.statusCode == 401) {
        throw CustomError(
          e.response?.data['message'] ?? 'Credenciales incorrectas',
        );
      }
      if (e.type == DioExceptionType.connectionTimeout) {
        throw CustomError('Revisar conexión a internet');
      }
      throw Exception();
    } catch (e) {
      print(e);
      throw Exception();
    }
  }

  @override
  Future<User> getEntidadesUsuario(String username) {
    throw UnimplementedError();
  }

  @override
  Future<User> login(String username, String password, String entidad) {
    throw UnimplementedError();
  }
}
