import 'package:app_gore_callao/features/auth/domain/domain.dart';
import '../infrastructure.dart';

class AuthRepositoryImpl extends AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl({AuthDataSource? dataSource})
    : dataSource = dataSource ?? AuthDataSourceImpl();

  @override
  Future<User> login(String username, String password, String codEntidad) {
    return dataSource.login(username, password, codEntidad);
  }
}
