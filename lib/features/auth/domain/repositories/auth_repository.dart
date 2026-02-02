import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> validarUsuario(String username);
  Future<User> login(String username, String password, String entidad);
}
