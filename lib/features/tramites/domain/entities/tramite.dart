class Tramite {
  final int id;
  final String codigo;
  final String titulo;
  final String fecha;
  final String estadoActual;
  final bool siguiendo;
  final int notificacionesNoLeidas;

  const Tramite({
    required this.id,
    required this.codigo,
    required this.titulo,
    required this.fecha,
    required this.estadoActual,
    required this.siguiendo,
    required this.notificacionesNoLeidas,
  });
}
