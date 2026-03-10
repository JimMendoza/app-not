import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/widgets/widgets.dart';
import 'package:app_gore_callao/features/shared/presentation/screens/layouts/header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
    final NotificacionesState notificacionesState = ref.watch(
      notificacionesProvider,
    );
    final NotificacionesNotifier notifier = ref.read(
      notificacionesProvider.notifier,
    );

    return Scaffold(
      appBar: Header(
        userName: authState.displayName,
        userEntity: authState.displayEntity,
        unreadNotifications: notificacionesState.noLeidas,
        onNotificationsClick: notifier.loadNotificaciones,
        onLogout: () {
          ref.read(authProvider.notifier).logout();
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: <Widget>[
                  _ResumenCard(
                    noLeidas: notificacionesState.noLeidas,
                    isLoading: notificacionesState.isLoadingResumen,
                    resumenError: notificacionesState.resumenError,
                    onRefresh: notifier.loadNotificaciones,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: notificacionesState.notificaciones.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (Object error, StackTrace _) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.notifications_off_outlined,
                                size: 40,
                                color: Color(0xFF99569E),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No se pudo cargar las notificaciones.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _readableError(error),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: notifier.loadNotificaciones,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      },
                      data: (List<Notificacion> notificaciones) {
                        if (notificaciones.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.notifications_none_rounded,
                                  size: 40,
                                  color: Color(0xFF99569E),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay notificaciones registradas.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: notifier.loadNotificaciones,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Actualizar'),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: notifier.loadNotificaciones,
                          child: ListView.separated(
                            itemCount: notificaciones.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final Notificacion notificacion =
                                  notificaciones[index];
                              return NotificacionCard(
                                notificacion: notificacion,
                                isMarkingAsRead: notificacionesState
                                    .isMarcarLeidaPending(notificacion.id),
                                onMarkAsRead: () async {
                                  final String? errorMessage =
                                      await notifier.marcarComoLeida(
                                        notificacion,
                                      );
                                  if (!context.mounted) {
                                    return;
                                  }

                                  if (errorMessage != null &&
                                      errorMessage.isNotEmpty) {
                                    _showSnackBar(
                                      context,
                                      _readableError(errorMessage),
                                    );
                                    return;
                                  }

                                  if (!notificacion.leida) {
                                    _showSnackBar(
                                      context,
                                      'Notificacion marcada como leida.',
                                    );
                                  }
                                },
                                onOpenTramite: () {
                                  if (notificacion.tramiteId <= 0) {
                                    _showSnackBar(
                                      context,
                                      'Esta notificacion no tiene tramite asociado.',
                                    );
                                    return;
                                  }

                                  final String encodedCodigo =
                                      Uri.encodeComponent(
                                        notificacion.codigoTramite,
                                      );
                                  context.push(
                                    '/tramites/${notificacion.tramiteId}/hoja-ruta?codigo=$encodedCodigo',
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final int noLeidas;
  final bool isLoading;
  final String resumenError;
  final VoidCallback onRefresh;

  const _ResumenCard({
    required this.noLeidas,
    required this.isLoading,
    required this.resumenError,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Notificaciones',
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF99569E),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF7F7E).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$noLeidas no leidas',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF7F7E),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: isLoading ? null : onRefresh,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Actualizar'),
              ),
            ],
          ),
          if (resumenError.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Resumen no sincronizado: $resumenError',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _readableError(Object error) {
  final String rawMessage = error.toString().trim();
  final String cleanMessage = rawMessage.replaceFirst(
    RegExp(r'^(Exception|CustomError):\s*'),
    '',
  );

  if (cleanMessage.isEmpty) {
    return 'Ocurrio un error inesperado.';
  }

  return cleanMessage;
}
