import 'dart:math';

import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/core/push/push_token_backend_client.dart';
import 'package:app_not/features/auth/domain/domain.dart';
import 'package:app_not/features/home/domain/domain.dart';
import 'package:app_not/features/notificaciones/domain/domain.dart';
import 'package:app_not/features/shared/infrastructure/services/key_value_storage_service.dart';
import 'package:app_not/features/tramites/domain/domain.dart';
import 'package:dio/dio.dart';

class InMemoryKeyValueStorageService implements KeyValueStorageService {
  final Map<String, Object?> _values;

  InMemoryKeyValueStorageService({Map<String, Object?> seed = const {}})
    : _values = Map<String, Object?>.from(seed);

  Map<String, Object?> get snapshot => Map<String, Object?>.unmodifiable(_values);

  @override
  Future<T?> getValue<T>(String key) async {
    final Object? value = _values[key];
    if (value == null) {
      return null;
    }

    return value as T;
  }

  @override
  Future<bool> removeKey(String key) async {
    return _values.remove(key) != null;
  }

  @override
  Future<void> removeKeys(Iterable<String> keys) async {
    for (final String key in keys) {
      _values.remove(key);
    }
  }

  @override
  Future<void> setKeyValue<T>(String key, T value) async {
    _values[key] = value;
  }
}

class FakePushTokenBackendClient extends PushTokenBackendClient {
  final List<String> invalidatedDeviceIds = <String>[];
  final List<Map<String, String>> upsertedTokens = <Map<String, String>>[];

  FakePushTokenBackendClient() : super(dio: Dio());

  @override
  Future<void> invalidatePushToken({required String deviceId}) async {
    invalidatedDeviceIds.add(deviceId);
  }

  @override
  Future<void> upsertPushToken({
    required String deviceId,
    required String pushToken,
    required String platform,
    required String deviceName,
    required String appVersion,
  }) async {
    upsertedTokens.add(<String, String>{
      'deviceId': deviceId,
      'pushToken': pushToken,
      'platform': platform,
      'deviceName': deviceName,
      'appVersion': appVersion,
    });
  }
}

class FakeAuthRepository implements AuthRepository {
  User? loginResponse;
  User? currentUserResponse;
  Object? loginError;
  Object? currentUserError;
  Object? logoutError;
  String? lastUsername;
  String? lastPassword;
  String? lastCodEntidad;
  String? lastLogoutDeviceId;

  FakeAuthRepository({this.loginResponse, this.currentUserResponse});

  @override
  Future<User> getCurrentUser() async {
    if (currentUserError != null) {
      throw currentUserError!;
    }

    final User? user = currentUserResponse;
    if (user == null) {
      throw const AppFailure(
        type: AppFailureType.serverError,
        message: 'FakeAuthRepository.currentUserResponse no configurado.',
      );
    }

    return user;
  }

  @override
  Future<User> login(String username, String password, String codEntidad) async {
    lastUsername = username;
    lastPassword = password;
    lastCodEntidad = codEntidad;

    if (loginError != null) {
      throw loginError!;
    }

    final User? user = loginResponse;
    if (user == null) {
      throw const AppFailure(
        type: AppFailureType.serverError,
        message: 'FakeAuthRepository.loginResponse no configurado.',
      );
    }

    return user;
  }

  @override
  Future<void> logout({String? deviceId}) async {
    lastLogoutDeviceId = deviceId;
    if (logoutError != null) {
      throw logoutError!;
    }
  }
}

class FakeEntidadRepository implements EntidadRepository {
  List<Entidad> entidades;
  Object? error;

  FakeEntidadRepository({this.entidades = const <Entidad>[]});

  @override
  Future<List<Entidad>> getEntidades() async {
    if (error != null) {
      throw error!;
    }

    return List<Entidad>.from(entidades);
  }
}

class FakeModuleRepository implements ModuleRepository {
  List<Module> modules;
  Object? error;

  FakeModuleRepository({this.modules = const <Module>[]});

  @override
  Future<List<Module>> getModules() async {
    if (error != null) {
      throw error!;
    }

    return List<Module>.from(modules);
  }
}

class FakeTramitesRepository implements TramitesRepository {
  List<Tramite> tramites;
  List<TramiteMovimiento> hojaRuta;
  Object? tramitesError;
  Object? hojaRutaError;
  final List<int> seguidos = <int>[];
  final List<int> noSeguidos = <int>[];

  FakeTramitesRepository({
    this.tramites = const <Tramite>[],
    this.hojaRuta = const <TramiteMovimiento>[],
  });

  @override
  Future<void> dejarDeSeguirTramite(int tramiteId) async {
    noSeguidos.add(tramiteId);
    tramites = tramites.map((Tramite tramite) {
      if (tramite.id != tramiteId) {
        return tramite;
      }

      return tramite.copyWith(siguiendo: false);
    }).toList(growable: false);
  }

  @override
  Future<List<TramiteMovimiento>> getHojaRuta(int tramiteId) async {
    if (hojaRutaError != null) {
      throw hojaRutaError!;
    }

    return List<TramiteMovimiento>.from(hojaRuta);
  }

  @override
  Future<List<Tramite>> getTramites() async {
    if (tramitesError != null) {
      throw tramitesError!;
    }

    return List<Tramite>.from(tramites);
  }

  @override
  Future<void> seguirTramite(int tramiteId) async {
    seguidos.add(tramiteId);
    tramites = tramites.map((Tramite tramite) {
      if (tramite.id != tramiteId) {
        return tramite;
      }

      return tramite.copyWith(siguiendo: true);
    }).toList(growable: false);
  }
}

class FakeNotificacionesRepository implements NotificacionesRepository {
  List<Notificacion> notificaciones;
  NotificacionesResumen resumen;
  NotificacionConfiguracion configuracion;
  Object? notificacionesError;
  Object? resumenError;
  Object? configuracionError;
  Object? guardarConfiguracionError;
  Object? marcarLeidaError;
  final List<int> markedAsRead = <int>[];
  final List<NotificacionConfiguracion> savedConfigurations =
      <NotificacionConfiguracion>[];

  FakeNotificacionesRepository({
    this.notificaciones = const <Notificacion>[],
    this.resumen = const NotificacionesResumen(noLeidas: 0),
    this.configuracion = const NotificacionConfiguracion(
      silenciarFueraDeHorario: false,
      horaSilencioInicio: '22:00',
      horaSilencioFin: '07:00',
      mostrarContadorNoLeidas: true,
    ),
  });

  @override
  Future<void> guardarConfiguracionNotificaciones(
    NotificacionConfiguracion configuracion,
  ) async {
    if (guardarConfiguracionError != null) {
      throw guardarConfiguracionError!;
    }

    this.configuracion = configuracion;
    savedConfigurations.add(configuracion);
  }

  @override
  Future<NotificacionConfiguracion> getConfiguracionNotificaciones() async {
    if (configuracionError != null) {
      throw configuracionError!;
    }

    return configuracion;
  }

  @override
  Future<List<Notificacion>> getNotificaciones() async {
    if (notificacionesError != null) {
      throw notificacionesError!;
    }

    return List<Notificacion>.from(notificaciones);
  }

  @override
  Future<NotificacionesResumen> getResumenNotificaciones() async {
    if (resumenError != null) {
      throw resumenError!;
    }

    return resumen;
  }

  @override
  Future<void> marcarComoLeida(int notificacionId) async {
    if (marcarLeidaError != null) {
      throw marcarLeidaError!;
    }

    markedAsRead.add(notificacionId);

    final bool wasUnread = notificaciones.any(
      (Notificacion notificacion) =>
          notificacion.id == notificacionId && !notificacion.leida,
    );

    notificaciones = notificaciones.map((Notificacion notificacion) {
      if (notificacion.id != notificacionId) {
        return notificacion;
      }

      return notificacion.copyWith(leida: true);
    }).toList(growable: false);

    if (wasUnread) {
      resumen = NotificacionesResumen(
        noLeidas: max(0, resumen.noLeidas - 1),
      );
    }
  }
}

User buildLoginUser({
  String username = '20131257750',
  String token = 'token-123',
  String tokenType = 'Bearer',
}) {
  return User(
    username: username,
    fullName: '',
    codEntidad: '',
    entidadNombre: '',
    permisos: const <String>[],
    token: token,
    tokenType: tokenType,
  );
}

User buildCanonicalUser({
  String username = '20131257750',
  String fullName = 'Juan Perez',
  String codEntidad = '0002',
  String entidadNombre = 'Gobierno Regional del Callao',
  List<String> permisos = const <String>['mobile'],
  String token = 'token-123',
  String tokenType = 'Bearer',
}) {
  return User(
    username: username,
    fullName: fullName,
    codEntidad: codEntidad,
    entidadNombre: entidadNombre,
    permisos: permisos,
    token: token,
    tokenType: tokenType,
  );
}

Entidad buildEntidad({
  String id = '0002',
  String nombre = 'Gobierno Regional del Callao',
  String imagen = '',
}) {
  return Entidad(id: id, nombre: nombre, imagen: imagen);
}

Module buildModule({
  required String id,
  required String nombre,
  String icono = 'apps',
}) {
  return Module(id: id, nombre: nombre, icono: icono);
}

Tramite buildTramite({
  required int id,
  String codigo = 'TR-001',
  String titulo = 'Mesa de Partes Virtual',
  String fecha = '2026-03-20T10:00:00',
  String estadoActual = 'Registrado',
  bool siguiendo = false,
  int notificacionesNoLeidas = 0,
}) {
  return Tramite(
    id: id,
    codigo: codigo,
    titulo: titulo,
    fecha: fecha,
    estadoActual: estadoActual,
    siguiendo: siguiendo,
    notificacionesNoLeidas: notificacionesNoLeidas,
  );
}

TramiteMovimiento buildMovimiento({
  String fechaHora = '2026-03-20 10:00',
  String nroDoc = 'DOC-001',
  String destino = 'Mesa de Partes',
  String estado = 'Registrado',
}) {
  return TramiteMovimiento(
    fechaHora: fechaHora,
    nroDoc: nroDoc,
    destino: destino,
    estado: estado,
  );
}

Notificacion buildNotificacion({
  required int id,
  required int tramiteId,
  String codigoTramite = 'TR-001',
  String titulo = 'Notificacion',
  String mensaje = 'Mensaje',
  String tipo = 'tramite_registrado',
  bool leida = false,
  String fechaHora = '2026-03-20T10:00:00',
}) {
  return Notificacion(
    id: id,
    tramiteId: tramiteId,
    codigoTramite: codigoTramite,
    titulo: titulo,
    mensaje: mensaje,
    tipo: tipo,
    leida: leida,
    fechaHora: fechaHora,
  );
}
