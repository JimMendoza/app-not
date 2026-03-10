import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/presentation/screens/layouts/header.dart';
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
    final AuthState authState = ref.watch(authProvider);
    final AsyncValue<List<TramiteMovimiento>> hojaRutaAsync = ref.watch(
      tramiteHojaRutaProvider(tramiteId),
    );
    final AsyncValue<int> noLeidasAsync = ref.watch(
      notificacionesNoLeidasProvider,
    );
    final int unreadNotifications = noLeidasAsync.asData?.value ?? 0;

    return Scaffold(
      appBar: Header(
        userName: authState.displayName,
        userEntity: authState.displayEntity,
        unreadNotifications: unreadNotifications,
        onNotificationsClick: () {
          context.go('/notificaciones');
        },
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
                  Container(
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
                          'Hoja de Ruta',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF99569E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tramite ${codigo.isNotEmpty ? codigo : '#$tramiteId'}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.grey[700],
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
                              Text(
                                'No se pudo cargar la hoja de ruta.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.grey[700],
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
                            child: Text(
                              'No hay movimientos registrados para este tramite.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: movimientos.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final TramiteMovimiento movimiento =
                                movimientos[index];
                            return _MovimientoCard(movimiento: movimiento);
                          },
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
}

class _MovimientoCard extends StatelessWidget {
  final TramiteMovimiento movimiento;

  const _MovimientoCard({required this.movimiento});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
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
              const Icon(Icons.schedule, size: 16, color: Color(0xFF99569E)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  movimiento.fechaHora,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF99569E),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF99569E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  movimiento.estado,
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF99569E),
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
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            movimiento.destino.isEmpty ? 'Sin destino' : movimiento.destino,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
