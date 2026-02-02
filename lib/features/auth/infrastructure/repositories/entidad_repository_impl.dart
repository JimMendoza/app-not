import 'package:app_gore_callao/features/auth/domain/domain.dart';
import '../infrastructure.dart';

class EntidadRepositoryImpl extends EntidadRepository {
  final EntidadDataSource dataSource;

  EntidadRepositoryImpl({EntidadDataSource? dataSource})
    : dataSource = dataSource ?? EntidadDatasourceImpl();
  @override
  Future<List<Entidad>> getEntidades() {
    return dataSource.getEntidades();
  }
}
