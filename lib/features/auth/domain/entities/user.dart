class User {
  final String username;
  final String fullName;
  final String codEntidad;
  final List<String> permisos;
  final String token;

  User({
    required this.username,
    required this.fullName,
    required this.codEntidad,
    required this.permisos,
    required this.token,
  });
}
