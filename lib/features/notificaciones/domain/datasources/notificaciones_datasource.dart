import '../entities/notificacion.dart';
import '../entities/notificaciones_resumen.dart';

abstract class NotificacionesDataSource {
  Future<List<Notificacion>> getNotificaciones();
  Future<NotificacionesResumen> getResumenNotificaciones();
  Future<void> marcarComoLeida(int notificacionId);
}
