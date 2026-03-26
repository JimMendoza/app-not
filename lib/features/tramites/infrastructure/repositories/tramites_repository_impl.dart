import 'package:app_not/features/tramites/domain/domain.dart';

class TramitesRepositoryImpl extends TramitesRepository {
  final TramitesDataSource dataSource;

  TramitesRepositoryImpl({required this.dataSource});

  @override
  Future<List<Tramite>> getTramites() {
    return dataSource.getTramites();
  }

  @override
  Future<void> seguirTramite(int tramiteId) {
    return dataSource.seguirTramite(tramiteId);
  }

  @override
  Future<void> dejarDeSeguirTramite(int tramiteId) {
    return dataSource.dejarDeSeguirTramite(tramiteId);
  }

  @override
  Future<List<TramiteMovimiento>> getHojaRuta(int tramiteId) {
    return dataSource.getHojaRuta(tramiteId);
  }
}

