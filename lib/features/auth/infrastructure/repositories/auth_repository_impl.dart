import 'package:app_gore_callao/features/auth/domain/domain.dart';
import '../infrastructure.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({AuthDataSource? dataSource})
    : dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<User> validarUsuario(String username) {
    return dataSource.validarUsuario(username);
  }

  @override
  Future<User> login(String username, String password, String entidad) {
    return dataSource.login(username, password, entidad);
  }
}
