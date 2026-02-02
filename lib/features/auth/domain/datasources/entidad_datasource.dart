import '../entities/entidad.dart';

abstract class EntidadDataSource {
  Future<List<Entidad>> getEntidades();
}
