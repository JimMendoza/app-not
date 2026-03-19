import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';

class NotificacionesRepositoryImpl extends NotificacionesRepository {
  final NotificacionesDataSource dataSource;

  NotificacionesRepositoryImpl({required this.dataSource});

  @override
  Future<List<Notificacion>> getNotificaciones() {
    return dataSource.getNotificaciones();
  }

  @override
  Future<NotificacionesResumen> getResumenNotificaciones() {
    return dataSource.getResumenNotificaciones();
  }

  @override
  Future<NotificacionConfiguracion> getConfiguracionNotificaciones() {
    return dataSource.getConfiguracionNotificaciones();
  }

  @override
  Future<void> guardarConfiguracionNotificaciones(
    NotificacionConfiguracion configuracion,
  ) {
    return dataSource.guardarConfiguracionNotificaciones(configuracion);
  }

  @override
  Future<void> marcarComoLeida(int notificacionId) {
    return dataSource.marcarComoLeida(notificacionId);
  }
}
