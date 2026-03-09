import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String username, String password, String codEntidad);
  Future<User> getCurrentUser();
  Future<void> logout();
}
