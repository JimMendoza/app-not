import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/presentation/helpers/helpers.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificacionesScreen extends ConsumerWidget {
  const NotificacionesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = context.appColors;
    final NotificacionesState notificacionesState = ref.watch(
      notificacionesProvider,
    );
    final NotificacionesNotifier notifier = ref.read(
      notificacionesProvider.notifier,
    );

    return SafeArea(
      child: Padding(
        padding: AppSpacing.all(AppSpacing.s16),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxFeatureWidth,
            ),
            child: Column(
              children: <Widget>[
                _ResumenCard(
                  noLeidas: notificacionesState.noLeidas,
                  isLoading: notificacionesState.isLoadingResumen,
                  resumenError: notificacionesState.resumenError,
                ),
                const SizedBox(height: AppSpacing.s16),
                Expanded(
                  child: notificacionesState.notificaciones.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (Object error, StackTrace _) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.notifications_off_outlined,
                              size: 40,
                              color: appColors.brandPrimary,
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            Text(
                              'No se pudo cargar las notificaciones.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: appColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s6),
                            Text(
                              AppErrorFormatter.readable(error),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 12,
                                color: appColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.s12),
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
                        return RefreshIndicator(
                          onRefresh: notifier.loadNotificaciones,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: <Widget>[
                              Padding(
                                padding: AppSpacing.symmetric(
                                  vertical: AppSpacing.s40,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      Icons.notifications_none_rounded,
                                      size: 40,
                                      color: appColors.brandPrimary,
                                    ),
                                    const SizedBox(height: AppSpacing.s12),
                                    Text(
                                      'No hay notificaciones registradas.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: appColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.s8),
                                    Text(
                                      'Desliza hacia abajo para actualizar.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: appColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: notifier.loadNotificaciones,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: notificaciones.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.s12),
                          itemBuilder: (context, index) {
                            final Notificacion notificacion =
                                notificaciones[index];
                            return NotificacionCard(
                              notificacion: notificacion,
                              isMarkingAsRead: notificacionesState
                                  .isMarcarLeidaPending(notificacion.id),
                              onMarkAsRead: () async {
                                final Object? actionError = await notifier
                                    .marcarComoLeida(notificacion);
                                if (!context.mounted) {
                                  return;
                                }

                                if (actionError != null) {
                                  AppSnackBarHelper.showError(
                                    context,
                                    actionError,
                                  );
                                  return;
                                }
                              },
                              onOpenTramite: () {
                                if (notificacion.tramiteId <= 0) {
                                  AppSnackBarHelper.showMessage(
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
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final int noLeidas;
  final bool isLoading;
  final String resumenError;

  const _ResumenCard({
    required this.noLeidas,
    required this.isLoading,
    required this.resumenError,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final AppStateStyle unreadStyle = AppStateStyles.resolve(
      context,
      AppStateTone.accent,
    );

    return Container(
      width: double.infinity,
      padding: AppSpacing.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.panel(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Notificaciones',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: appColors.brandPrimary,
                  ),
                ),
              ),
              if (isLoading) ...<Widget>[
                const SizedBox(
                  width: AppComponentSizes.inlineLoader,
                  height: AppComponentSizes.inlineLoader,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppSpacing.s10),
              ],
              Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.s12,
                  vertical: AppSpacing.s6,
                ),
                decoration: BoxDecoration(
                  color: unreadStyle.background,
                  borderRadius: AppRadii.pillRadius,
                  border: Border.all(color: unreadStyle.border),
                ),
                child: Text(
                  '$noLeidas no leidas',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: unreadStyle.foreground,
                  ),
                ),
              ),
            ],
          ),
          if (resumenError.isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.s8),
            Text(
              'Resumen no sincronizado: $resumenError',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: appColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
