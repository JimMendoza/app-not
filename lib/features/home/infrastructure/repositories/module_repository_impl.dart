import 'package:app_gore_callao/features/home/domain/domain.dart';

class ModuleRepositoryImpl extends ModuleRepository {
  final ModuleDataSource dataSource;

  ModuleRepositoryImpl({required this.dataSource});

  @override
  Future<List<Module>> getModules() {
    return dataSource.getModules();
  }
}
