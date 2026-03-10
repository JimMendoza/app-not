import '../entities/module.dart';

abstract class ModuleDataSource {
  Future<List<Module>> getModules();
}
