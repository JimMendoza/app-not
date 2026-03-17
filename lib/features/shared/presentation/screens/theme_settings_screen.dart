import 'package:app_gore_callao/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode currentThemeMode = ref.watch(appThemeModeProvider);
    final AppThemeModeNotifier themeModeNotifier = ref.read(
      appThemeModeProvider.notifier,
    );
    final appColors = context.appColors;

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
                _SettingsHeader(
                  title: 'Tema',
                  subtitle:
                      'Selecciona como quieres que se vea la aplicacion en este dispositivo.',
                  onBack: () => _goBack(context),
                ),
                const SizedBox(height: AppSpacing.s16),
                Container(
                  padding: AppSpacing.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: appColors.surfacePrimary,
                    borderRadius: AppRadii.cardRadius,
                    boxShadow: AppShadows.panel(context),
                  ),
                  child: RadioGroup<ThemeMode>(
                    groupValue: currentThemeMode,
                    onChanged: (ThemeMode? selectedMode) {
                      if (selectedMode == null) {
                        return;
                      }

                      themeModeNotifier.setThemeMode(selectedMode);
                    },
                    child: Column(
                      children: const <Widget>[
                        _ThemeModeOption(
                          value: ThemeMode.light,
                          title: 'Claro',
                          subtitle: 'Usa la paleta clara del aplicativo.',
                          icon: Icons.light_mode_outlined,
                        ),
                        _ThemeModeOption(
                          value: ThemeMode.dark,
                          title: 'Oscuro',
                          subtitle: 'Usa la paleta oscura del aplicativo.',
                          icon: Icons.dark_mode_outlined,
                        ),
                        _ThemeModeOption(
                          value: ThemeMode.system,
                          title: 'Sistema',
                          subtitle:
                              'Sigue automaticamente el tema configurado en el dispositivo.',
                          icon: Icons.settings_suggest_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/home');
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBack;

  const _SettingsHeader({
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

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
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: appColors.brandPrimary,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
              ),
            ],
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

class _ThemeModeOption extends StatelessWidget {
  final ThemeMode value;
  final String title;
  final String subtitle;
  final IconData icon;

  const _ThemeModeOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Container(
      margin: AppSpacing.only(bottom: AppSpacing.s12),
      decoration: BoxDecoration(
        color: appColors.surfaceSecondary,
        borderRadius: AppRadii.mediumRadius,
      ),
      child: ListTile(
        contentPadding: AppSpacing.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s6,
        ),
        leading: Icon(icon, color: appColors.brandPrimary),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontSize: 15,
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
        trailing: Radio<ThemeMode>(value: value),
        onTap: () {
          final RadioGroupRegistry<ThemeMode>? group =
              RadioGroup.maybeOf<ThemeMode>(context);
          group?.onChanged(value);
        },
      ),
    );
  }
}
