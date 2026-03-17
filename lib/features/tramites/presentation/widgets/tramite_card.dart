import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/tramites/domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TramiteCard extends StatelessWidget {
  final Tramite tramite;
  final bool isSeguimientoLoading;
  final VoidCallback onToggleSeguimiento;
  final VoidCallback onOpenHojaRuta;

  const TramiteCard({
    super.key,
    required this.tramite,
    this.isSeguimientoLoading = false,
    required this.onToggleSeguimiento,
    required this.onOpenHojaRuta,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final AppStateStyle notificationStyle = AppStateStyles.resolve(
      context,
      AppStateTone.accent,
    );

    return Container(
      padding: AppSpacing.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.card(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  tramite.codigo.isEmpty ? 'SIN-CODIGO' : tramite.codigo,
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: appColors.brandPrimary,
                  ),
                ),
              ),
              if (tramite.notificacionesNoLeidas > 0)
                Container(
                  padding: AppSpacing.symmetric(
                    horizontal: AppSpacing.s10,
                    vertical: AppSpacing.s4,
                  ),
                  decoration: BoxDecoration(
                    color: notificationStyle.foreground,
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Text(
                    '${tramite.notificacionesNoLeidas}',
                    style: GoogleFonts.montserrat(
                      color: appColors.onBrand,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            tramite.titulo,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          Wrap(
            spacing: AppSpacing.s8,
            runSpacing: AppSpacing.s8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.calendar_month,
                    size: 16,
                    color: appColors.textMuted,
                  ),
                  const SizedBox(width: AppSpacing.s4),
                  Text(
                    tramite.fecha,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      color: appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s14),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isSeguimientoLoading ? null : onToggleSeguimiento,
                  icon: isSeguimientoLoading
                      ? const SizedBox(
                          width: AppComponentSizes.inlineLoader,
                          height: AppComponentSizes.inlineLoader,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          tramite.siguiendo
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18,
                        ),
                  label: Text(
                    isSeguimientoLoading
                        ? 'Procesando...'
                        : tramite.siguiendo
                        ? 'Dejar de seguir'
                        : 'Seguir',
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onOpenHojaRuta,
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
