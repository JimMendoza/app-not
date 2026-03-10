import '../entities/module.dart';

abstract class ModuleRepository {
  Future<List<Module>> getModules();
}
