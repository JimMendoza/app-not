import '../entities/user.dart';

abstract class AuthDataSource {
  Future<User> login(String username, String password, String codEntidad);
}
