import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/home/domain/domain.dart';

class ModuleMapper {
  static const String _invalidModulesMessage =
      'Respuesta invalida del servidor al cargar /app/modulos.';

  static Module moduleJsonToEntity(Map<String, dynamic> json) => Module(
    id: ResponseContractValidator.expectString(
      json,
      'id',
      message: _invalidModulesMessage,
      allowEmpty: false,
    ),
    nombre: ResponseContractValidator.expectString(
      json,
      'nombre',
      message: _invalidModulesMessage,
      allowEmpty: false,
    ),
    icono: ResponseContractValidator.expectString(
      json,
      'icono',
      message: _invalidModulesMessage,
    ),
  );

  static List<Module> moduleListJsonToEntity(List<dynamic> jsonList) {
    final List<Map<String, dynamic>> modules =
        ResponseContractValidator.expectMapList(
          jsonList,
          message: _invalidModulesMessage,
        );

    return modules.map(moduleJsonToEntity).toList(growable: false);
  }
}
