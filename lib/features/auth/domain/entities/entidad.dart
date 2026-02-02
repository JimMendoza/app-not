class Entidad {
  final String id;
  final String siglas;
  final String nombre;
  final String? claims;
  final String? imagen;

  Entidad({
    required this.id,
    required this.siglas,
    required this.nombre,
    this.claims,
    this.imagen,
  });
}
