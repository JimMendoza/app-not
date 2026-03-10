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

  Tramite copyWith({
    int? id,
    String? codigo,
    String? titulo,
    String? fecha,
    String? estadoActual,
    bool? siguiendo,
    int? notificacionesNoLeidas,
  }) => Tramite(
    id: id ?? this.id,
    codigo: codigo ?? this.codigo,
    titulo: titulo ?? this.titulo,
    fecha: fecha ?? this.fecha,
    estadoActual: estadoActual ?? this.estadoActual,
    siguiendo: siguiendo ?? this.siguiendo,
    notificacionesNoLeidas:
        notificacionesNoLeidas ?? this.notificacionesNoLeidas,
  );
}
