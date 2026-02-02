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

      print('=== RESPUESTA DEL API ===');
      print('Status: ${response.statusCode}');
      print('Data type: ${response.data.runtimeType}');
      print('Data: ${response.data}');

      // Asumiendo que la respuesta es una lista o tiene una propiedad con la lista
      final List<dynamic> jsonList = response.data is List
          ? response.data
          : response.data['data'] ?? response.data['entidades'] ?? [];

      print('Lista extraída: ${jsonList.length} entidades');

      final data = EntidadMapper.entidadListJsonToEntity(jsonList);
      print('Entidades mapeadas: ${data.length}');

      return data;
    } catch (e) {
      print('Error al cargar entidades: $e');
      throw Exception('Error al cargar entidades: $e');
    }
  }
}
