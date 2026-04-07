import '../entities/user.dart';

abstract class AuthDataSource {
  Future<User> login(
    String username,
    String password,
    String codEntidad,
    String deviceId,
  );
  Future<User> getCurrentUser();
  Future<void> logout({String? deviceId});
}
