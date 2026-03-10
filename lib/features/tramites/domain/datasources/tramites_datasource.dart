import '../entities/tramite.dart';

abstract class TramitesDataSource {
  Future<List<Tramite>> getTramites();
}
