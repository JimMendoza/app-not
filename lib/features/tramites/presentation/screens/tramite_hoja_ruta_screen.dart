import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/tramites/domain/domain.dart';
import 'package:app_gore_callao/features/tramites/presentation/providers/providers.dart';
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
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: appColors.surfacePrimary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: appColors.shadowSoft,
                        blurRadius: 18,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                      const SizedBox(height: 6),
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
                const SizedBox(height: 16),
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
                            const SizedBox(height: 12),
                            Text(
                              'No se pudo cargar la hoja de ruta.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: appColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
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
                            const SizedBox(height: 12),
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
                              const SizedBox(height: 12),
                              Text(
                                'No hay movimientos registrados para este tramite.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: appColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
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
                              const SizedBox(height: 10),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: appColors.shadowSoft,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.schedule, size: 16, color: appColors.brandPrimary),
              const SizedBox(width: 6),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: appColors.brandPrimarySoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  movimiento.estado,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: appColors.brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            movimiento.nroDoc.isEmpty ? 'Sin documento' : movimiento.nroDoc,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
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
