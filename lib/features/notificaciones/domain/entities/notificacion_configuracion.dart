class NotificacionConfiguracion {
  final bool silenciarFueraDeHorario;
  final String horaSilencioInicio;
  final String horaSilencioFin;
  final bool mostrarContadorNoLeidas;

  const NotificacionConfiguracion({
    required this.silenciarFueraDeHorario,
    required this.horaSilencioInicio,
    required this.horaSilencioFin,
    required this.mostrarContadorNoLeidas,
  });

  NotificacionConfiguracion copyWith({
    bool? silenciarFueraDeHorario,
    String? horaSilencioInicio,
    String? horaSilencioFin,
    bool? mostrarContadorNoLeidas,
  }) => NotificacionConfiguracion(
    silenciarFueraDeHorario:
        silenciarFueraDeHorario ?? this.silenciarFueraDeHorario,
    horaSilencioInicio: horaSilencioInicio ?? this.horaSilencioInicio,
    horaSilencioFin: horaSilencioFin ?? this.horaSilencioFin,
    mostrarContadorNoLeidas:
        mostrarContadorNoLeidas ?? this.mostrarContadorNoLeidas,
  );

  bool hasSameValues(NotificacionConfiguracion other) {
    return silenciarFueraDeHorario == other.silenciarFueraDeHorario &&
        horaSilencioInicio == other.horaSilencioInicio &&
        horaSilencioFin == other.horaSilencioFin &&
        mostrarContadorNoLeidas == other.mostrarContadorNoLeidas;
  }
}
