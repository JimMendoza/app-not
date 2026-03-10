import 'package:app_gore_callao/features/tramites/domain/domain.dart';

class TramitesRepositoryImpl extends TramitesRepository {
  final TramitesDataSource dataSource;

  TramitesRepositoryImpl({required this.dataSource});

  @override
  Future<List<Tramite>> getTramites() {
    return dataSource.getTramites();
  }
}
