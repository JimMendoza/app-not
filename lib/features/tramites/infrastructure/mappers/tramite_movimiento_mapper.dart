import 'package:app_gore_callao/features/tramites/domain/domain.dart';

class TramiteMovimientoMapper {
  static TramiteMovimiento tramiteMovimientoJsonToEntity(
    Map<String, dynamic> json,
  ) => TramiteMovimiento(
    fechaHora: (json['fechaHora']?.toString() ?? '').trim(),
    nroDoc: (json['nroDoc']?.toString() ?? '').trim(),
    destino: (json['destino']?.toString() ?? '').trim(),
    estado: (json['estado']?.toString() ?? '').trim(),
  );

  static List<TramiteMovimiento> tramiteMovimientoListJsonToEntity(
    List<dynamic> jsonList,
  ) {
    return jsonList
        .whereType<Map<String, dynamic>>()
        .map(tramiteMovimientoJsonToEntity)
        .toList();
  }
}
