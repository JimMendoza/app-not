import '../entities/notificacion.dart';
import '../entities/notificacion_configuracion.dart';
import '../entities/notificaciones_resumen.dart';

abstract class NotificacionesRepository {
  Future<List<Notificacion>> getNotificaciones();
  Future<NotificacionesResumen> getResumenNotificaciones();
  Future<NotificacionConfiguracion> getConfiguracionNotificaciones();
  Future<void> guardarConfiguracionNotificaciones(
    NotificacionConfiguracion configuracion,
  );
  Future<void> marcarComoLeida(int notificacionId);
}
