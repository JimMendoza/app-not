import '../entities/tramite.dart';
import '../entities/tramite_movimiento.dart';

abstract class TramitesDataSource {
  Future<List<Tramite>> getTramites();
  Future<void> seguirTramite(int tramiteId);
  Future<void> dejarDeSeguirTramite(int tramiteId);
  Future<List<TramiteMovimiento>> getHojaRuta(int tramiteId);
}
