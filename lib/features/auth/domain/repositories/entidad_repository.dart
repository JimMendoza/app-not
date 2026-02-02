import '../entities/entidad.dart';

abstract class EntidadRepository {
  Future<List<Entidad>> getEntidades();
}
