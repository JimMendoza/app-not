import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/notificaciones/domain/domain.dart';
import 'package:app_gore_callao/features/notificaciones/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/infrastructure/widgets/widgets.dart';
import 'package:app_gore_callao/features/shared/presentation/helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final NotificacionConfiguracionState state = ref.watch(
      notificacionConfiguracionProvider,
    );
    final NotificacionConfiguracionNotifier notifier = ref.read(
      notificacionConfiguracionProvider.notifier,
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: AppSpacing.all(AppSpacing.s16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppLayout.maxFeatureWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _HeaderCard(
                  title: 'Configuracion de notificaciones',
                  subtitle: 'Administra preferencias de las notificaciones.',
                ),
                const SizedBox(height: AppSpacing.s16),
                if (state.saveError.isNotEmpty) ...<Widget>[
                  AppInlineBanner(
                    message: state.saveError,
                    variant: AppInlineBannerVariant.error,
                    onClose: notifier.clearSaveFeedback,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],
                if (state.saveSuccessMessage.isNotEmpty) ...<Widget>[
                  AppInlineBanner(
                    message: state.saveSuccessMessage,
                    variant: AppInlineBannerVariant.success,
                    onClose: notifier.clearSaveFeedback,
                  ),
                  const SizedBox(height: AppSpacing.s12),
                ],
                state.configuracion.when(
                  loading: () => const _LoadingPanel(),
                  error: (Object error, StackTrace _) => _LoadErrorPanel(
                    message: AppErrorFormatter.readable(error),
                    onRetry: notifier.loadConfiguracion,
                  ),
                  data: (NotificacionConfiguracion configuracion) {
                    return _SettingsPanel(
                      configuracion: configuracion,
                      hasChanges: state.hasChanges,
                      isSaving: state.isSaving,
                      onSoloTramitesSeguidosChanged:
                          notifier.setSoloTramitesSeguidos,
                      onNotificarCambiosEstadoChanged:
                          notifier.setNotificarCambiosEstado,
                      onNotificarMovimientosHojaRutaChanged:
                          notifier.setNotificarMovimientosHojaRuta,
                      onSoloEventosImportantesChanged:
                          notifier.setSoloEventosImportantes,
                      onFrecuenciaChanged: notifier.setFrecuenciaNotificacion,
                      onSilenciarFueraDeHorarioChanged:
                          notifier.setSilenciarFueraDeHorario,
                      onMostrarContadorNoLeidasChanged:
                          notifier.setMostrarContadorNoLeidas,
                      onSave: () async {
                        final Object? actionError = await notifier
                            .saveConfiguracion();
                        if (!context.mounted) {
                          return;
                        }

                        if (actionError != null) {
                          AppSnackBarHelper.showError(context, actionError);
                          return;
                        }

                        AppSnackBarHelper.showMessage(
                          context,
                          'Configuracion de notificaciones guardada.',
                          isError: false,
                        );
                      },
                      onRefresh: notifier.loadConfiguracion,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
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
            title,
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: appColors.brandPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 14,
              color: appColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: AppSpacing.all(AppSpacing.s24),
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.panel(context),
      ),
      child: const Column(
        children: <Widget>[
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.s12),
          Text('Cargando configuracion de notificaciones...'),
        ],
      ),
    );
  }
}

class _LoadErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
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
              Icon(Icons.error_outline, color: appColors.brandPrimary),
              const SizedBox(width: AppSpacing.s8),
              Text(
                'No se pudo cargar la configuracion',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s8),
          Text(
            message,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: appColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final NotificacionConfiguracion configuracion;
  final bool hasChanges;
  final bool isSaving;
  final ValueChanged<bool> onSoloTramitesSeguidosChanged;
  final ValueChanged<bool> onNotificarCambiosEstadoChanged;
  final ValueChanged<bool> onNotificarMovimientosHojaRutaChanged;
  final ValueChanged<bool> onSoloEventosImportantesChanged;
  final ValueChanged<FrecuenciaNotificacion> onFrecuenciaChanged;
  final ValueChanged<bool> onSilenciarFueraDeHorarioChanged;
  final ValueChanged<bool> onMostrarContadorNoLeidasChanged;
  final Future<void> Function() onSave;
  final Future<void> Function() onRefresh;

  const _SettingsPanel({
    required this.configuracion,
    required this.hasChanges,
    required this.isSaving,
    required this.onSoloTramitesSeguidosChanged,
    required this.onNotificarCambiosEstadoChanged,
    required this.onNotificarMovimientosHojaRutaChanged,
    required this.onSoloEventosImportantesChanged,
    required this.onFrecuenciaChanged,
    required this.onSilenciarFueraDeHorarioChanged,
    required this.onMostrarContadorNoLeidasChanged,
    required this.onSave,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (isSaving)
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.s12),
            child: LinearProgressIndicator(),
          ),
        _SectionCard(
          title: 'Reglas',
          subtitle: 'Filtros y eventos habilitados',
          children: <Widget>[
            _SettingSwitchTile(
              title: 'Solo tramites seguidos',
              subtitle:
                  'Limita notificaciones a tramites que sigues activamente.',
              value: configuracion.soloTramitesSeguidos,
              enabled: !isSaving,
              onChanged: onSoloTramitesSeguidosChanged,
            ),
            const SizedBox(height: AppSpacing.s8),
            _SettingSwitchTile(
              title: 'Notificar cambios de estado',
              subtitle: 'Recibe alertas cuando el estado del tramite cambie.',
              value: configuracion.notificarCambiosEstado,
              enabled: !isSaving,
              onChanged: onNotificarCambiosEstadoChanged,
            ),
            const SizedBox(height: AppSpacing.s8),
            _SettingSwitchTile(
              title: 'Notificar movimientos de hoja de ruta',
              subtitle: 'Recibe alertas por movimientos en hoja de ruta.',
              value: configuracion.notificarMovimientosHojaRuta,
              enabled: !isSaving,
              onChanged: onNotificarMovimientosHojaRutaChanged,
            ),
            const SizedBox(height: AppSpacing.s8),
            _SettingSwitchTile(
              title: 'Solo eventos importantes',
              subtitle:
                  'Filtra alertas para mostrar unicamente eventos relevantes.',
              value: configuracion.soloEventosImportantes,
              enabled: !isSaving,
              onChanged: onSoloEventosImportantesChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        _SectionCard(
          title: 'Frecuencia',
          subtitle: 'Valor permitido por backend',
          children: <Widget>[
            RadioGroup<FrecuenciaNotificacion>(
              groupValue: configuracion.frecuenciaNotificacion,
              onChanged: (FrecuenciaNotificacion? selected) {
                if (isSaving || selected == null) {
                  return;
                }
                onFrecuenciaChanged(selected);
              },
              child: Column(
                children: <Widget>[
                  _FrequencyTile(
                    title: 'Inmediatas',
                    subtitle: 'frecuencia_notificacion = inmediatas',
                    value: FrecuenciaNotificacion.inmediatas,
                    enabled: !isSaving,
                  ),
                  const SizedBox(height: AppSpacing.s8),
                  _FrequencyTile(
                    title: 'Resumen diario',
                    subtitle: 'frecuencia_notificacion = resumen_diario',
                    value: FrecuenciaNotificacion.resumenDiario,
                    enabled: !isSaving,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s12),
        _SectionCard(
          title: 'Comportamiento',
          subtitle: 'Silencio y contador de no leidas',
          children: <Widget>[
            _SettingSwitchTile(
              title: 'Silenciar fuera de horario',
              subtitle:
                  'Silencia alertas fuera de la ventana horaria configurada.',
              value: configuracion.silenciarFueraDeHorario,
              enabled: !isSaving,
              onChanged: onSilenciarFueraDeHorarioChanged,
            ),
            const SizedBox(height: AppSpacing.s8),
            _SettingSwitchTile(
              title: 'Mostrar contador de no leidas',
              subtitle: 'Muestra badge con total de notificaciones no leidas.',
              value: configuracion.mostrarContadorNoLeidas,
              enabled: !isSaving,
              onChanged: onMostrarContadorNoLeidasChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s16),
        Row(
          children: <Widget>[
            Expanded(
              child: FilledButton.icon(
                onPressed: (!hasChanges || isSaving)
                    ? null
                    : () {
                        onSave();
                      },
                icon: isSaving
                    ? const SizedBox(
                        width: AppComponentSizes.inlineLoader,
                        height: AppComponentSizes.inlineLoader,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(isSaving ? 'Guardando...' : 'Guardar cambios'),
              ),
            ),
            const SizedBox(width: AppSpacing.s10),
            OutlinedButton.icon(
              onPressed: isSaving
                  ? null
                  : () {
                      onRefresh();
                    },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Recargar'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Text(
          hasChanges
              ? 'Tienes cambios pendientes por guardar.'
              : 'Configuracion sincronizada.',
          style: GoogleFonts.montserrat(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: hasChanges ? appColors.brandPrimary : appColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      padding: AppSpacing.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: appColors.surfacePrimary,
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.panel(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.s4),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              color: appColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.s12),
          ...children,
        ],
      ),
    );
  }
}

class _SettingSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SettingSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: appColors.surfaceSecondary,
        borderRadius: AppRadii.mediumRadius,
      ),
      child: SwitchListTile.adaptive(
        contentPadding: AppSpacing.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s4,
        ),
        value: value,
        onChanged: enabled ? onChanged : null,
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: appColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: appColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _FrequencyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final FrecuenciaNotificacion value;
  final bool enabled;

  const _FrequencyTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: appColors.surfaceSecondary,
        borderRadius: AppRadii.mediumRadius,
      ),
      child: ListTile(
        contentPadding: AppSpacing.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s4,
        ),
        onTap: enabled
            ? () {
                final RadioGroupRegistry<FrecuenciaNotificacion>? group =
                    RadioGroup.maybeOf<FrecuenciaNotificacion>(context);
                group?.onChanged(value);
              }
            : null,
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: appColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 12,
            color: appColors.textSecondary,
          ),
        ),
        trailing: Radio<FrecuenciaNotificacion>(value: value),
      ),
    );
  }
}
