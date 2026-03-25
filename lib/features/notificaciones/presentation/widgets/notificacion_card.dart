import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificacionCard extends StatelessWidget {
  final Notificacion notificacion;
  final bool isOpeningDetalle;
  final VoidCallback onOpenDetalle;

  const NotificacionCard({
    super.key,
    required this.notificacion,
    this.isOpeningDetalle = false,
    required this.onOpenDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notificacion.leida;
    final AppStateStyle seguimientoStyle = AppStateStyles.resolve(
      context,
      AppStateTone.brand,
    );
    final appColors = context.appColors;

    return Container(
      padding: AppSpacing.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isUnread
            ? seguimientoStyle.background
            : appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        border: Border.all(
          color: isUnread ? seguimientoStyle.border : appColors.transparent,
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
                    color: appColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: isOpeningDetalle ? null : onOpenDetalle,
                tooltip: 'Ver detalle',
                icon: isOpeningDetalle
                    ? const SizedBox(
                        width: AppComponentSizes.inlineLoader,
                        height: AppComponentSizes.inlineLoader,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.visibility_outlined,
                        color: appColors.brandPrimary,
                      ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            notificacion.mensaje.isEmpty ? 'Sin mensaje' : notificacion.mensaje,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: appColors.textSecondary,
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
              _ReadStatusPill(isUnread: isUnread),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReadStatusPill extends StatelessWidget {
  final bool isUnread;

  const _ReadStatusPill({required this.isUnread});

  @override
  Widget build(BuildContext context) {
    final AppStateStyle readStyle = AppStateStyles.resolve(
      context,
      isUnread ? AppStateTone.accent : AppStateTone.success,
    );

    return Container(
      padding: AppSpacing.symmetric(
        horizontal: AppSpacing.s10,
        vertical: AppSpacing.s6,
      ),
      decoration: BoxDecoration(
        color: readStyle.background,
        borderRadius: AppRadii.pillRadius,
        border: Border.all(color: readStyle.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            isUnread ? Icons.mark_email_unread_outlined : Icons.mark_email_read,
            size: 14,
            color: readStyle.foreground,
          ),
          const SizedBox(width: AppSpacing.s4),
          Text(
            isUnread ? 'No leida' : 'Leida',
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: readStyle.foreground,
            ),
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
