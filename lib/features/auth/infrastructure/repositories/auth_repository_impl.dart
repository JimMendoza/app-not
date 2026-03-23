import 'package:app_gore_callao/features/auth/domain/domain.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<User> login(String username, String password, String codEntidad) {
    return dataSource.login(username, password, codEntidad);
  }

  @override
  Future<User> getCurrentUser() {
    return dataSource.getCurrentUser();
  }

  @override
  Future<void> logout({String? deviceId}) {
    return dataSource.logout(deviceId: deviceId);
  }
}
