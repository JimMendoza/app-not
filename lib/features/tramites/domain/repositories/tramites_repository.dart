import '../entities/tramite.dart';

abstract class TramitesRepository {
  Future<List<Tramite>> getTramites();
}
