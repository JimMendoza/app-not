import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/providers.dart';
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
    final TramitesState tramitesState = ref.watch(tramitesProvider);
    final TramitesNotifier tramitesNotifier = ref.read(tramitesProvider.notifier);
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
                    child: tramitesState.tramites.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (Object error, StackTrace _) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.cloud_off_rounded,
                                size: 40,
                                color: Color(0xFF99569E),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No se pudo cargar los tramites.',
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
                                onPressed: tramitesNotifier.loadTramites,
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      },
                      data: (List<Tramite> tramites) {
                        if (tramites.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.assignment_outlined,
                                  size: 40,
                                  color: Color(0xFF99569E),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No hay tramites registrados para este usuario.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextButton.icon(
                                  onPressed: tramitesNotifier.loadTramites,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Actualizar'),
                                ),
                              ],
                            ),
                          );
                        }

                        return RefreshIndicator(
                          onRefresh: tramitesNotifier.loadTramites,
                          child: ListView.separated(
                            itemCount: tramites.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final Tramite tramite = tramites[index];
                              return TramiteCard(
                                tramite: tramite,
                                isSeguimientoLoading: tramitesState
                                    .isSeguimientoPending(tramite.id),
                                onToggleSeguimiento: () async {
                                  final String? errorMessage =
                                      await tramitesNotifier.toggleSeguimiento(
                                        tramite,
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
                                  }
                                },
                                onOpenHojaRuta: () {
                                  final String encodedCodigo =
                                      Uri.encodeComponent(tramite.codigo);
                                  context.push(
                                    '/tramites/${tramite.id}/hoja-ruta?codigo=$encodedCodigo',
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
