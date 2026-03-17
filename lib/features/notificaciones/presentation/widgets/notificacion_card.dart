import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificacionCard extends StatelessWidget {
  final Notificacion notificacion;
  final bool isMarkingAsRead;
  final VoidCallback onMarkAsRead;
  final VoidCallback onOpenTramite;

  const NotificacionCard({
    super.key,
    required this.notificacion,
    this.isMarkingAsRead = false,
    required this.onMarkAsRead,
    required this.onOpenTramite,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notificacion.leida;
    final appColors = context.appColors;
    final AppStateStyle readStyle = AppStateStyles.resolve(
      context,
      isUnread ? AppStateTone.accent : AppStateTone.success,
    );
    final AppStateStyle brandStyle = AppStateStyles.resolve(
      context,
      AppStateTone.brand,
    );

    return Container(
      padding: AppSpacing.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isUnread
            ? context.appColors.surfaceMuted
            : context.appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: isUnread ? brandStyle.border : context.appColors.transparent,
        ),
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  notificacion.titulo.isEmpty
                      ? 'Sin titulo'
                      : notificacion.titulo,
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.appColors.textPrimary,
                  ),
                ),
              ),
              _TipoBadge(tipo: notificacion.tipo, isUnread: isUnread),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            notificacion.mensaje.isEmpty ? 'Sin mensaje' : notificacion.mensaje,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            children: <Widget>[
              _InfoPill(
                icon: Icons.receipt_long,
                text: notificacion.codigoTramite.isEmpty
                    ? 'Sin codigo'
                    : notificacion.codigoTramite,
              ),
              _InfoPill(
                icon: Icons.schedule,
                text: notificacion.fechaHora.isEmpty
                    ? 'Sin fecha'
                    : notificacion.fechaHora,
              ),
              Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: readStyle.background,
                  borderRadius: AppRadii.pillRadius,
                  border: Border.all(color: readStyle.border),
                ),
                child: Text(
                  isUnread ? 'No leida' : 'Leida',
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: readStyle.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isUnread && !isMarkingAsRead ? onMarkAsRead : null,
                  icon: isMarkingAsRead
                      ? const SizedBox(
                          width: AppComponentSizes.inlineLoader,
                          height: AppComponentSizes.inlineLoader,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          isUnread
                              ? Icons.mark_email_read
                              : Icons.check_circle_outline,
                          size: 18,
                        ),
                  label: Text(
                    isMarkingAsRead
                        ? 'Procesando...'
                        : isUnread
                        ? 'Marcar leida'
                        : 'Leida',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenTramite,
                  style: FilledButton.styleFrom(
                    backgroundColor: appColors.brandPrimary,
                  ),
                  icon: const Icon(Icons.alt_route, size: 18),
                  label: const Text('Hoja de ruta'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({required this.icon, required this.text});

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

class _TipoBadge extends StatelessWidget {
  final String tipo;
  final bool isUnread;

  const _TipoBadge({required this.tipo, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    final AppStateStyle badgeStyle = AppStateStyles.resolve(
      context,
      isUnread ? AppStateTone.brand : AppStateTone.neutral,
    );

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: badgeStyle.background,
        borderRadius: AppRadii.pillRadius,
        border: Border.all(color: badgeStyle.border),
      ),
      child: Text(
        tipo.isEmpty ? 'INFO' : tipo,
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: badgeStyle.foreground,
        ),
      ),
    );
  }
}
