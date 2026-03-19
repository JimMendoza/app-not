import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/home/domain/domain.dart';
import 'package:app_gore_callao/features/home/infrastructure/mappers/module_mapper.dart';
import 'package:dio/dio.dart';

class ModuleDataSourceImpl extends ModuleDataSource {
  final Dio dio;

  ModuleDataSourceImpl({required this.dio});

  @override
  Future<List<Module>> getModules() async {
    try {
      final Response<dynamic> response = await dio.get('/app/modulos');
      final List<dynamic> modulesJson = ResponseContractValidator.expectList(
        response.data,
        message: 'Respuesta invalida del servidor al cargar /app/modulos.',
      );
      return ModuleMapper.moduleListJsonToEntity(modulesJson);
    } on DioException catch (e) {
      throw DioErrorMapper.map(
        e,
        fallbackMessage: 'No se pudo cargar los modulos.',
      );
    } catch (e) {
      if (e is AppFailure) {
        rethrow;
      }

      throw DioErrorMapper.unknown(
        e,
        message: 'No se pudo cargar los modulos.',
      );
    }
  }
}
