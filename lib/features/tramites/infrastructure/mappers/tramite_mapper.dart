import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/tramites/domain/domain.dart';

class TramiteMapper {
  static const String _invalidTramitesMessage =
      'Respuesta invalida del servidor al cargar /app/tramites.';

  static Tramite tramiteJsonToEntity(Map<String, dynamic> json) => Tramite(
    id: ResponseContractValidator.expectInt(
      json,
      'id',
      message: _invalidTramitesMessage,
    ),
    codigo: ResponseContractValidator.expectString(
      json,
      'codigo',
      message: _invalidTramitesMessage,
    ),
    titulo: ResponseContractValidator.expectString(
      json,
      'titulo',
      message: _invalidTramitesMessage,
    ),
    fecha: ResponseContractValidator.expectString(
      json,
      'fecha',
      message: _invalidTramitesMessage,
    ),
    estadoActual: ResponseContractValidator.expectString(
      json,
      'estadoActual',
      message: _invalidTramitesMessage,
    ),
    siguiendo: ResponseContractValidator.expectBool(
      json,
      'siguiendo',
      message: _invalidTramitesMessage,
    ),
    notificacionesNoLeidas: ResponseContractValidator.expectInt(
      json,
      'notificacionesNoLeidas',
      message: _invalidTramitesMessage,
    ),
  );

  static List<Tramite> tramiteListJsonToEntity(List<dynamic> jsonList) {
    final List<Map<String, dynamic>> tramites =
        ResponseContractValidator.expectMapList(
          jsonList,
          message: _invalidTramitesMessage,
        );

    return tramites.map(tramiteJsonToEntity).toList(growable: false);
  }
}
