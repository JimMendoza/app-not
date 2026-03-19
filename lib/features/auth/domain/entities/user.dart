class User {
  final String username;
  final String fullName;
  final String codEntidad;
  final String entidadNombre;
  final List<String> permisos;
  final String token;
  final String tokenType;

  User({
    required this.username,
    required this.fullName,
    required this.codEntidad,
    required this.entidadNombre,
    required this.permisos,
    required this.token,
    required this.tokenType,
  });

  User copyWith({
    String? username,
    String? fullName,
    String? codEntidad,
    String? entidadNombre,
    List<String>? permisos,
    String? token,
    String? tokenType,
  }) => User(
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    codEntidad: codEntidad ?? this.codEntidad,
    entidadNombre: entidadNombre ?? this.entidadNombre,
    permisos: permisos ?? this.permisos,
    token: token ?? this.token,
    tokenType: tokenType ?? this.tokenType,
  );
}
