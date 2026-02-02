import '../entities/user.dart';

abstract class AuthDataSource {
  Future<User> validarUsuario(String username);
  Future<User> login(String username, String password, String entidad);
}
