import 'package:dio/dio.dart';
import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';

class EntidadDatasourceImpl extends EntidadDataSource {
  final dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  @override
  Future<List<Entidad>> getEntidades() async {
    try {
      final response = await dio.post('/app/entidades');

      final List<dynamic> jsonList = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['entidades'] ?? [];

      final data = EntidadMapper.entidadListJsonToEntity(jsonList);

      return data;
    } catch (e) {
      throw Exception('Error al cargar entidades: $e');
    }
  }
}
