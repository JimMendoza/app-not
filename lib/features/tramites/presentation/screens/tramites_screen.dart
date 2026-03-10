import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/presentation/screens/layouts/header.dart';
import 'package:app_gore_callao/features/tramites/domain/domain.dart';
import 'package:app_gore_callao/features/tramites/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/tramites/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TramitesScreen extends ConsumerWidget {
  const TramitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState authState = ref.watch(authProvider);
    final AsyncValue<List<Tramite>> tramitesAsync = ref.watch(tramitesProvider);

    return Scaffold(
      appBar: Header(
        userName: authState.displayName,
        userEntity: authState.displayEntity,
        unreadNotifications: 0,
        onNotificationsClick: () {
          context.go('/modulo/notificaciones?nombre=Notificaciones');
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
                          'Mesa de Partes Virtual',
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF99569E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Listado de tramites del usuario autenticado',
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
                    child: tramitesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (Object error, StackTrace stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                'No se pudo cargar los tramites.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: () => ref.refresh(tramitesProvider),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      },
                      data: (List<Tramite> tramites) {
                        if (tramites.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay tramites registrados para este usuario.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: tramites.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final Tramite tramite = tramites[index];
                            return TramiteCard(
                              tramite: tramite,
                              onToggleSeguimiento: () {
                                _showPendingAction(
                                  context,
                                  tramite.siguiendo
                                      ? 'Dejar de seguir se conectara en el siguiente bloque.'
                                      : 'Seguir tramite se conectara en el siguiente bloque.',
                                );
                              },
                              onOpenHojaRuta: () {
                                final String encodedCodigo = Uri.encodeComponent(
                                  tramite.codigo,
                                );
                                context.go(
                                  '/tramites/${tramite.id}/hoja-ruta?codigo=$encodedCodigo',
                                );
                              },
                            );
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

  void _showPendingAction(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
