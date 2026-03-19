enum FrecuenciaNotificacion { inmediatas, resumenDiario }

extension FrecuenciaNotificacionX on FrecuenciaNotificacion {
  String get backendValue {
    return switch (this) {
      FrecuenciaNotificacion.inmediatas => 'inmediatas',
      FrecuenciaNotificacion.resumenDiario => 'resumen_diario',
    };
  }

  static FrecuenciaNotificacion fromBackendValue(dynamic value) {
    final String normalized = value?.toString().trim().toLowerCase() ?? '';
    return normalized == 'resumen_diario'
        ? FrecuenciaNotificacion.resumenDiario
        : FrecuenciaNotificacion.inmediatas;
  }
}

class NotificacionConfiguracion {
  final bool soloTramitesSeguidos;
  final bool notificarCambiosEstado;
  final bool notificarMovimientosHojaRuta;
  final bool soloEventosImportantes;
  final FrecuenciaNotificacion frecuenciaNotificacion;
  final bool silenciarFueraDeHorario;
  final bool mostrarContadorNoLeidas;

  const NotificacionConfiguracion({
    required this.soloTramitesSeguidos,
    required this.notificarCambiosEstado,
    required this.notificarMovimientosHojaRuta,
    required this.soloEventosImportantes,
    required this.frecuenciaNotificacion,
    required this.silenciarFueraDeHorario,
    required this.mostrarContadorNoLeidas,
  });

  NotificacionConfiguracion copyWith({
    bool? soloTramitesSeguidos,
    bool? notificarCambiosEstado,
    bool? notificarMovimientosHojaRuta,
    bool? soloEventosImportantes,
    FrecuenciaNotificacion? frecuenciaNotificacion,
    bool? silenciarFueraDeHorario,
    bool? mostrarContadorNoLeidas,
  }) => NotificacionConfiguracion(
    soloTramitesSeguidos: soloTramitesSeguidos ?? this.soloTramitesSeguidos,
    notificarCambiosEstado:
        notificarCambiosEstado ?? this.notificarCambiosEstado,
    notificarMovimientosHojaRuta:
        notificarMovimientosHojaRuta ?? this.notificarMovimientosHojaRuta,
    soloEventosImportantes:
        soloEventosImportantes ?? this.soloEventosImportantes,
    frecuenciaNotificacion:
        frecuenciaNotificacion ?? this.frecuenciaNotificacion,
    silenciarFueraDeHorario:
        silenciarFueraDeHorario ?? this.silenciarFueraDeHorario,
    mostrarContadorNoLeidas:
        mostrarContadorNoLeidas ?? this.mostrarContadorNoLeidas,
  );

  bool hasSameValues(NotificacionConfiguracion other) {
    return soloTramitesSeguidos == other.soloTramitesSeguidos &&
        notificarCambiosEstado == other.notificarCambiosEstado &&
        notificarMovimientosHojaRuta == other.notificarMovimientosHojaRuta &&
        soloEventosImportantes == other.soloEventosImportantes &&
        frecuenciaNotificacion == other.frecuenciaNotificacion &&
        silenciarFueraDeHorario == other.silenciarFueraDeHorario &&
        mostrarContadorNoLeidas == other.mostrarContadorNoLeidas;
  }
}
