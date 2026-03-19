import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/shared/presentation/helpers/helpers.dart';
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
    final appColors = context.appColors;
    final TramitesState tramitesState = ref.watch(tramitesProvider);
    final TramitesNotifier tramitesNotifier = ref.read(
      tramitesProvider.notifier,
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
                      Text(
                        'Mesa de Partes Virtual',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: appColors.brandPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        'Listado de tramites',
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
                  child: tramitesState.tramites.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (Object error, StackTrace _) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.cloud_off_rounded,
                              size: 40,
                              color: appColors.brandPrimary,
                            ),
                            const SizedBox(height: AppSpacing.s12),
                            Text(
                              'No se pudo cargar los tramites.',
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
                              Icon(
                                Icons.assignment_outlined,
                                size: 40,
                                color: appColors.brandPrimary,
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              Text(
                                'No hay tramites registrados para este usuario.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: appColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s12),
                              TextButton.icon(
                                onPressed: tramitesNotifier.loadTramites,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Actualizar'),
                              ),
                            ],
                          ),
                        );
                      }

                      final List<Tramite> tramitesEnSeguimiento = tramites
                          .where((Tramite item) => item.siguiendo)
                          .toList();
                      final List<Tramite> otrosTramites = tramites
                          .where((Tramite item) => !item.siguiendo)
                          .toList();

                      return RefreshIndicator(
                        onRefresh: tramitesNotifier.loadTramites,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: <Widget>[
                            TramitesSection(
                              storageId: 'seguimiento',
                              title: 'Tramites en seguimiento',
                              count: tramitesEnSeguimiento.length,
                              emptyMessage:
                                  'Aun no sigues ningun tramite. Los tramites que marques con seguimiento apareceran aqui.',
                              icon: Icons.visibility_outlined,
                              children: tramitesEnSeguimiento
                                  .map(
                                    (Tramite tramite) => _buildTramiteCard(
                                      context,
                                      tramite: tramite,
                                      tramitesState: tramitesState,
                                      tramitesNotifier: tramitesNotifier,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: AppSpacing.s16),
                            TramitesSection(
                              storageId: 'otros',
                              title: 'Otros tramites',
                              count: otrosTramites.length,
                              emptyMessage:
                                  'No hay mas tramites disponibles fuera del seguimiento actual.',
                              icon: Icons.assignment_outlined,
                              children: otrosTramites
                                  .map(
                                    (Tramite tramite) => _buildTramiteCard(
                                      context,
                                      tramite: tramite,
                                      tramitesState: tramitesState,
                                      tramitesNotifier: tramitesNotifier,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: AppSpacing.s16),
                          ],
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

  Widget _buildTramiteCard(
    BuildContext context, {
    required Tramite tramite,
    required TramitesState tramitesState,
    required TramitesNotifier tramitesNotifier,
  }) {
    return TramiteCard(
      tramite: tramite,
      isSeguimientoLoading: tramitesState.isSeguimientoPending(tramite.id),
      onToggleSeguimiento: () async {
        final Object? actionError = await tramitesNotifier.toggleSeguimiento(
          tramite,
        );
        if (!context.mounted) {
          return;
        }

        if (actionError != null) {
          AppSnackBarHelper.showError(context, actionError);
        }
      },
      onOpenHojaRuta: () {
        final String encodedCodigo = Uri.encodeComponent(tramite.codigo);
        context.push('/tramites/${tramite.id}/hoja-ruta?codigo=$encodedCodigo');
      },
    );
  }
}
