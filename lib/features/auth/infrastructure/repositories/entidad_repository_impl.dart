import 'package:app_gore_callao/features/auth/domain/domain.dart';

class EntidadRepositoryImpl extends EntidadRepository {
  final EntidadDataSource dataSource;

  EntidadRepositoryImpl({required this.dataSource});

  @override
  Future<List<Entidad>> getEntidades() {
    return dataSource.getEntidades();
  }
}
