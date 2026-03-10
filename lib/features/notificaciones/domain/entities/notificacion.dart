class Notificacion {
  final int id;
  final int tramiteId;
  final String codigoTramite;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool leida;
  final String fechaHora;

  const Notificacion({
    required this.id,
    required this.tramiteId,
    required this.codigoTramite,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.leida,
    required this.fechaHora,
  });

  Notificacion copyWith({
    int? id,
    int? tramiteId,
    String? codigoTramite,
    String? titulo,
    String? mensaje,
    String? tipo,
    bool? leida,
    String? fechaHora,
  }) => Notificacion(
    id: id ?? this.id,
    tramiteId: tramiteId ?? this.tramiteId,
    codigoTramite: codigoTramite ?? this.codigoTramite,
    titulo: titulo ?? this.titulo,
    mensaje: mensaje ?? this.mensaje,
    tipo: tipo ?? this.tipo,
    leida: leida ?? this.leida,
    fechaHora: fechaHora ?? this.fechaHora,
  );
}
