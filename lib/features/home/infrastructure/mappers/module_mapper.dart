import 'package:app_gore_callao/features/home/domain/domain.dart';

class ModuleMapper {
  static Module moduleJsonToEntity(Map<String, dynamic> json) => Module(
    id:
        (json['id']?.toString() ?? json['codigo']?.toString() ?? '').trim(),
    nombre:
        (json['nombre']?.toString() ??
                json['name']?.toString() ??
                'Modulo sin nombre')
            .trim(),
    icono: (json['icono']?.toString() ?? json['icon']?.toString() ?? '').trim(),
  );

  static List<Module> moduleListJsonToEntity(List<dynamic> jsonList) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(moduleJsonToEntity)
        .toList();
  }
}
