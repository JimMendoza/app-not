import 'package:dio/dio.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/infrastructure/infrastructure.dart';

class EntidadDatasourceImpl extends EntidadDataSource {
  final Dio dio;

  EntidadDatasourceImpl({required this.dio});

  @override
  Future<List<Entidad>> getEntidades() async {
    try {
      final Response<dynamic> response = await dio.post(
        '/app/entidades',
        options: Options(extra: <String, bool>{'skipAuth': true}),
      );

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
