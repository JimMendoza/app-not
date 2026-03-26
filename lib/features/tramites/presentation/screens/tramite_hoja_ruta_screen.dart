import 'package:app_not/config/config.dart';
import 'package:app_not/core/errors/errors.dart';
import 'package:app_not/features/tramites/domain/domain.dart';
import 'package:app_not/features/tramites/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TramiteHojaRutaScreen extends ConsumerWidget {
  final int tramiteId;
  final String codigo;

  const TramiteHojaRutaScreen({
    super.key,
    required this.tramiteId,
    required this.codigo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = context.appColors;
    final AsyncValue<List<TramiteMovimiento>> hojaRutaAsync = ref.watch(
      tramiteHojaRutaProvider(tramiteId),
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
                Container(
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
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Hoja de Ruta',
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: appColors.brandPrimary,
                              ),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                                return;
                              }

                              context.go('/tramites');
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Volver'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        'Tramite ${codigo.isNotEmpty ? codigo : '#$tramiteId'}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: appColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.s16),
                Expanded(
                  child: hojaRutaAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (Object error, StackTrace _) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.route_outlined,
                              size: 40,
                              color: appColors.brandPrimary,
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            Text(
                              'No se pudo cargar la hoja de ruta.',
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
                              onPressed: () => ref.refresh(
                                tramiteHojaRutaProvider(tramiteId),
                              ),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    },
                    data: (List<TramiteMovimiento> movimientos) {
                      if (movimientos.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.timeline_outlined,
                                size: 40,
                                color: appColors.brandPrimary,
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              Text(
                                'No hay movimientos registrados para este tramite.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: appColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              TextButton.icon(
                                onPressed: () => ref.refresh(
                                  tramiteHojaRutaProvider(tramiteId),
                                ),
                                icon: const Icon(Icons.refresh),
                                label: const Text('Actualizar'),
                              ),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(tramiteHojaRutaProvider(tramiteId));
                          await ref.read(
                            tramiteHojaRutaProvider(tramiteId).future,
                          );
                        },
                        child: ListView.separated(
                          itemCount: movimientos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.s10),
                          itemBuilder: (context, index) {
                            final TramiteMovimiento movimiento =
                                movimientos[index];
                            return _MovimientoCard(movimiento: movimiento);
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

class _MovimientoCard extends StatelessWidget {
  final TramiteMovimiento movimiento;

  const _MovimientoCard({required this.movimiento});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final AppStateStyle statusStyle = AppStateStyles.resolve(
      context,
      AppStateTone.brand,
    );

    return Container(
      padding: AppSpacing.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: AppRadii.xLargeRadius,
        boxShadow: AppShadows.subtle(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.schedule, size: 16, color: appColors.brandPrimary),
              const SizedBox(width: AppSpacing.s6),
              Expanded(
                child: Text(
                  movimiento.fechaHora,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: appColors.brandPrimary,
                  ),
                ),
              ),
              Container(
                padding: AppSpacing.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: statusStyle.background,
                  borderRadius: AppRadii.pillRadius,
                  border: Border.all(color: statusStyle.border),
                ),
                child: Text(
                  movimiento.estado,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusStyle.foreground,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            movimiento.nroDoc.isEmpty ? 'Sin documento' : movimiento.nroDoc,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s6),
          Text(
            movimiento.destino.isEmpty ? 'Sin destino' : movimiento.destino,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

