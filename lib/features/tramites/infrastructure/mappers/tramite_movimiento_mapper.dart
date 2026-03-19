import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/tramites/domain/domain.dart';

class TramiteMovimientoMapper {
  static const String _invalidHojaRutaMessage =
      'Respuesta invalida del servidor al cargar la hoja de ruta.';

  static TramiteMovimiento tramiteMovimientoJsonToEntity(
    Map<String, dynamic> json,
  ) => TramiteMovimiento(
    fechaHora: ResponseContractValidator.expectString(
      json,
      'fechaHora',
      message: _invalidHojaRutaMessage,
    ),
    nroDoc: ResponseContractValidator.expectString(
      json,
      'nroDoc',
      message: _invalidHojaRutaMessage,
    ),
    destino: ResponseContractValidator.expectString(
      json,
      'destino',
      message: _invalidHojaRutaMessage,
    ),
    estado: ResponseContractValidator.expectString(
      json,
      'estado',
      message: _invalidHojaRutaMessage,
    ),
  );

  static List<TramiteMovimiento> tramiteMovimientoListJsonToEntity(
    List<dynamic> jsonList,
  ) {
    final List<Map<String, dynamic>> movimientos =
        ResponseContractValidator.expectMapList(
          jsonList,
          message: _invalidHojaRutaMessage,
        );

    return movimientos
        .map(tramiteMovimientoJsonToEntity)
        .toList(growable: false);
  }
}
