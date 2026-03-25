import 'dart:async';

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

class NotificacionesScreen extends ConsumerStatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  ConsumerState<NotificacionesScreen> createState() =>
      _NotificacionesScreenState();
}

class _NotificacionesScreenState extends ConsumerState<NotificacionesScreen> {
  int? _requestedNotificationIdFromRoute;
  int? _handledAutoOpenNotificationId;
  bool _isAutoOpenScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final int? routeNotificationId = _extractNotificationIdFromRoute(context);
    if (routeNotificationId == _requestedNotificationIdFromRoute) {
      return;
    }

    _requestedNotificationIdFromRoute = routeNotificationId;
    _isAutoOpenScheduled = false;
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final NotificacionesState notificacionesState = ref.watch(
      notificacionesProvider,
    );
    final bool shouldShowUnreadCounter = ref
        .watch(notificacionesBadgeVisiblePreferenceProvider)
        .maybeWhen(data: (bool value) => value, orElse: () => true);
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
                  showUnreadCounter: shouldShowUnreadCounter,
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
                      _scheduleAutoOpenFromPushTap(
                        notifier: notifier,
                        notificaciones: notificaciones,
                      );

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
                              isOpeningDetalle: notificacionesState
                                  .isMarcarLeidaPending(notificacion.id),
                              onOpenDetalle: () => unawaited(
                                _openNotificacionDetalle(
                                  notifier: notifier,
                                  notificacion: notificacion,
                                ),
                              ),
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

  Future<void> _openNotificacionDetalle({
    required NotificacionesNotifier notifier,
    required Notificacion notificacion,
  }) async {
    final Notificacion? current = _findNotificacionById(
      ref.read(notificacionesProvider).notificaciones.asData?.value ??
          const <Notificacion>[],
      notificacion.id,
    );
    final Notificacion detalle = current ?? notificacion;

    unawaited(_markAsReadOnOpen(notifier: notifier, notificacion: detalle));

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return _NotificacionDetalleSheet(
          notificationId: detalle.id,
          fallbackNotificacion: detalle,
        );
      },
    );
  }

  Future<void> _markAsReadOnOpen({
    required NotificacionesNotifier notifier,
    required Notificacion notificacion,
  }) async {
    if (notificacion.leida) {
      return;
    }

    final Object? actionError = await notifier.marcarComoLeida(notificacion);
    if (!mounted || actionError == null) {
      return;
    }

    AppSnackBarHelper.showError(context, actionError);
  }

  void _scheduleAutoOpenFromPushTap({
    required NotificacionesNotifier notifier,
    required List<Notificacion> notificaciones,
  }) {
    final int? requestedId = _requestedNotificationIdFromRoute;
    if (requestedId == null ||
        requestedId == _handledAutoOpenNotificationId ||
        _isAutoOpenScheduled) {
      return;
    }

    _isAutoOpenScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final Notificacion? target = _findNotificacionById(
        notificaciones,
        requestedId,
      );

      if (target == null) {
        AppSnackBarHelper.showMessage(
          context,
          'No se encontro la notificacion seleccionada.',
          isError: false,
        );
      } else {
        await _openNotificacionDetalle(
          notifier: notifier,
          notificacion: target,
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _handledAutoOpenNotificationId = requestedId;
        _isAutoOpenScheduled = false;
      });
    });
  }

  int? _extractNotificationIdFromRoute(BuildContext context) {
    final String? rawNotificationId = GoRouterState.of(
      context,
    ).uri.queryParameters['notificationId'];
    if (rawNotificationId == null || rawNotificationId.trim().isEmpty) {
      return null;
    }

    return int.tryParse(rawNotificationId.trim());
  }

  Notificacion? _findNotificacionById(
    List<Notificacion> notificaciones,
    int notificationId,
  ) {
    for (final Notificacion notificacion in notificaciones) {
      if (notificacion.id == notificationId) {
        return notificacion;
      }
    }

    return null;
  }
}

class _NotificacionDetalleSheet extends ConsumerWidget {
  final int notificationId;
  final Notificacion fallbackNotificacion;

  const _NotificacionDetalleSheet({
    required this.notificationId,
    required this.fallbackNotificacion,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Notificacion selectedNotificacion = _resolveCurrentNotificacion(ref);
    final appColors = context.appColors;
    final String titulo = selectedNotificacion.titulo.isEmpty
        ? 'Sin titulo'
        : selectedNotificacion.titulo;
    final String mensaje = selectedNotificacion.mensaje.isEmpty
        ? 'Sin mensaje'
        : selectedNotificacion.mensaje;
    final String codigoTramite = selectedNotificacion.codigoTramite.trim();
    final String fechaHora = selectedNotificacion.fechaHora.isEmpty
        ? 'Sin fecha'
        : selectedNotificacion.fechaHora;
    final String tipo = _toFriendlyTipo(selectedNotificacion.tipo);
    final String estadoLectura = selectedNotificacion.leida
        ? 'Leida'
        : 'No leida';
    final AppStateStyle lecturaStyle = AppStateStyles.resolve(
      context,
      selectedNotificacion.leida ? AppStateTone.success : AppStateTone.accent,
    );

    return SafeArea(
      child: Padding(
        padding: AppSpacing.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s12,
          AppSpacing.s20,
          AppSpacing.s24,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                titulo,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: appColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.s12),
              Text(
                mensaje,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: appColors.textSecondary,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.s16),
              Wrap(
                spacing: AppSpacing.s8,
                runSpacing: AppSpacing.s8,
                children: <Widget>[
                  if (codigoTramite.isNotEmpty)
                    _DetallePill(
                      icon: Icons.receipt_long_rounded,
                      text: codigoTramite,
                    ),
                  _DetallePill(icon: Icons.schedule_rounded, text: fechaHora),
                  _DetallePill(icon: Icons.label_outline_rounded, text: tipo),
                  Container(
                    padding: AppSpacing.symmetric(
                      horizontal: AppSpacing.s10,
                      vertical: AppSpacing.s6,
                    ),
                    decoration: BoxDecoration(
                      color: lecturaStyle.background,
                      borderRadius: AppRadii.pillRadius,
                      border: Border.all(color: lecturaStyle.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          selectedNotificacion.leida
                              ? Icons.mark_email_read
                              : Icons.mark_email_unread_outlined,
                          size: 14,
                          color: lecturaStyle.foreground,
                        ),
                        const SizedBox(width: AppSpacing.s4),
                        Text(
                          estadoLectura,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: lecturaStyle.foreground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.s20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Notificacion _resolveCurrentNotificacion(WidgetRef ref) {
    final List<Notificacion>? currentList = ref
        .watch(notificacionesProvider)
        .notificaciones
        .asData
        ?.value;

    if (currentList == null) {
      return fallbackNotificacion;
    }

    for (final Notificacion item in currentList) {
      if (item.id == notificationId) {
        return item;
      }
    }

    return fallbackNotificacion;
  }

  String _toFriendlyTipo(String rawTipo) {
    switch (rawTipo.trim().toLowerCase()) {
      case 'tramite_registrado':
        return 'Tramite registrado';
      case 'tramite_derivado':
        return 'Tramite derivado';
      case 'estado':
        return 'Cambio de estado';
      case 'movimiento_hoja_ruta':
        return 'Movimiento de tramite';
      default:
        return 'Notificacion';
    }
  }
}

class _DetallePill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetallePill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final AppStateStyle neutralStyle = AppStateStyles.resolve(
      context,
      AppStateTone.neutral,
    );

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: neutralStyle.background,
        borderRadius: AppRadii.pillRadius,
        border: Border.all(color: neutralStyle.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: neutralStyle.foreground),
          const SizedBox(width: AppSpacing.s4),
          Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: neutralStyle.foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenCard extends StatelessWidget {
  final int noLeidas;
  final bool showUnreadCounter;
  final bool isLoading;
  final String resumenError;

  const _ResumenCard({
    required this.noLeidas,
    required this.showUnreadCounter,
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
              if (showUnreadCounter)
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
