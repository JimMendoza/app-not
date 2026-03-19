import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';

class NotificacionConfiguracionMapper {
  static NotificacionConfiguracion jsonToEntity(Map<String, dynamic> json) {
    return NotificacionConfiguracion(
      soloTramitesSeguidos: _toBool(json['solo_tramites_seguidos']),
      notificarCambiosEstado: _toBool(json['notificar_cambios_estado']),
      notificarMovimientosHojaRuta: _toBool(
        json['notificar_movimientos_hoja_ruta'],
      ),
      soloEventosImportantes: _toBool(json['solo_eventos_importantes']),
      frecuenciaNotificacion: FrecuenciaNotificacionX.fromBackendValue(
        json['frecuencia_notificacion'],
      ),
      silenciarFueraDeHorario: _toBool(json['silenciar_fuera_de_horario']),
      mostrarContadorNoLeidas: _toBool(json['mostrar_contador_no_leidas']),
    );
  }

  static Map<String, dynamic> entityToJson(NotificacionConfiguracion entity) {
    return <String, dynamic>{
      'solo_tramites_seguidos': entity.soloTramitesSeguidos,
      'notificar_cambios_estado': entity.notificarCambiosEstado,
      'notificar_movimientos_hoja_ruta': entity.notificarMovimientosHojaRuta,
      'solo_eventos_importantes': entity.soloEventosImportantes,
      'frecuencia_notificacion': entity.frecuenciaNotificacion.backendValue,
      'silenciar_fuera_de_horario': entity.silenciarFueraDeHorario,
      'mostrar_contador_no_leidas': entity.mostrarContadorNoLeidas,
    };
  }

  static bool _toBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    if (value is String) {
      final String normalized = value.trim().toLowerCase();
      return normalized == '1' ||
          normalized == 'true' ||
          normalized == 'si' ||
          normalized == 'yes' ||
          normalized == 'on';
    }

    return false;
  }
}
