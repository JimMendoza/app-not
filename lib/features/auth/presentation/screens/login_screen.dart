import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/core/errors/errors.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_gore_callao/features/shared/infrastructure/widgets/widgets.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    final entidadesAsync = ref.watch(entidadesProvider);
    final appColors = context.appColors;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    Image.asset(
                      'assets/img/logo_gore.png',
                      width: 300,
                      height: 200,
                    ),
                    Text(
                      Environment.appLema,
                      style: AppTextStyles.medium20Accent(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Formulario
              entidadesAsync.when(
                data: (entidades) {
                  if (entidades.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 48,
                              color: appColors.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay entidades disponibles.',
                              style: AppTextStyles.regular16Accent(context),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => ref.refresh(entidadesProvider),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return _LoginForm(loginForm: loginForm, entidades: entidades);
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: appColors.danger,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar entidades',
                          style: AppTextStyles.regular16Accent(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppErrorFormatter.readable(error),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.regular14Secondary(context),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => ref.refresh(entidadesProvider),
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
                child: Column(
                  children: [
                    // const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 8),
                        Text(
                          Environment.appCopyright,
                          style: AppTextStyles.regular14Secondary(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends ConsumerWidget {
  final LoginFormState loginForm;
  final List<Entidad> entidades;

  const _LoginForm({required this.loginForm, required this.entidades});

  bool _canProceed(LoginFormState state) {
    if (state.isSubmitting) {
      return false;
    }

    if (state.step == 1) {
      return state.entity.isNotEmpty;
    }

    if (state.step == 2) {
      return state.username.isValid && state.password.isValid;
    }

    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(loginFormProvider.notifier);
    final authState = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    final appColors = context.appColors;
    final Map<String, Entidad> entitiesByName = <String, Entidad>{
      for (final Entidad entidad in entidades) entidad.nombre: entidad,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de pasos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [1, 2].map((p) {
                    return Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: loginForm.step == p
                            ? appColors.brandPrimary
                            : loginForm.step > p
                            ? appColors.brandAccent
                            : appColors.borderSubtle,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$p',
                          style: TextStyle(
                            color: loginForm.step >= p
                                ? appColors.onBrand
                                : appColors.textMuted,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Text(
                  'Paso ${loginForm.step}/2',
                  style: AppTextStyles.regular14Secondary(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (authState.errorMessage.isNotEmpty) ...[
              AppInlineBanner(
                message: authState.errorMessage,
                variant: _authBannerVariant(authState.errorType),
                onClose: authNotifier.clearErrorMessage,
              ),
              const SizedBox(height: 16),
            ],

            // Paso 1: Seleccionar Entidad
            if (loginForm.step == 1) ...[
              const SizedBox(height: 16),
              Text(
                'Seleccione su entidad',
                style: AppTextStyles.bold16Primary(context),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 288),
                child: SingleChildScrollView(
                  child: RadioGroup<String>(
                    groupValue: loginForm.entity.isEmpty
                        ? null
                        : loginForm.entity,
                    onChanged: (String? value) {
                      if (loginForm.isSubmitting) {
                        return;
                      }

                      if (value == null) {
                        return;
                      }

                      final Entidad? selectedEntidad = entitiesByName[value];
                      if (selectedEntidad == null) {
                        return;
                      }

                      notifier.onEntityChanged(
                        selectedEntidad.nombre,
                        selectedEntidad.id,
                        selectedEntidad.imagen,
                      );
                    },
                    child: Column(
                      children: entidades.map((Entidad entidad) {
                        final bool isSelected =
                            loginForm.entity.isNotEmpty &&
                            loginForm.entity == entidad.nombre;

                        return GestureDetector(
                          onTap: loginForm.isSubmitting
                              ? null
                              : () => notifier.onEntityChanged(
                                  entidad.nombre,
                                  entidad.id,
                                  entidad.imagen,
                                ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? appColors.brandPrimary
                                    : appColors.borderSubtle,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              color: isSelected
                                  ? appColors.brandPrimary.withValues(
                                      alpha: 0.08,
                                    )
                                  : appColors.surfacePrimary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  // Logo de la entidad
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: appColors.surfaceSecondary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: entidad.imagen.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              entidad.imagen,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.business,
                                                      size: 32,
                                                      color:
                                                          appColors.textMuted,
                                                    );
                                                  },
                                            ),
                                          )
                                        : Icon(
                                            Icons.business,
                                            size: 32,
                                            color: appColors.textMuted,
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Nombre de la entidad
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entidad.nombre,
                                          style:
                                              AppTextStyles.regular13Secondary(
                                                context,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Radio button
                                  Radio<String>(
                                    value: entidad.nombre,
                                    activeColor: appColors.brandPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],

            // Paso 2: Usuario y Contraseña
            if (loginForm.step == 2) ...[
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Usuario',
                onChanged: loginForm.isSubmitting
                    ? null
                    : notifier.onUsernameChanged,
                errorMessage: loginForm.username.errorMessage,
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Contraseña',
                obscureText: !loginForm.showPassword,
                errorMessage: loginForm.password.errorMessage,
                onChanged: loginForm.isSubmitting
                    ? null
                    : notifier.onPasswordChanged,
                suffixIcon: IconButton(
                  icon: Icon(
                    loginForm.showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: loginForm.isSubmitting
                      ? null
                      : notifier.toggleShowPassword,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: appColors.brandAccentSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SelectedEntityLogo(imageUrl: loginForm.entityImage),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Entidad: ${loginForm.entity}',
                        style: AppTextStyles.medium14Primary(context),
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: loginForm.rememberMe,
                    onChanged: loginForm.isSubmitting
                        ? null
                        : (value) => notifier.toggleRememberMe(value ?? false),
                  ),
                  Text(
                    'Recordarme en este dispositivo',
                    style: TextStyle(
                      fontSize: 14,
                      color: appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Botones de navegación
            Row(
              children: [
                if (loginForm.step > 1) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: loginForm.isSubmitting
                          ? null
                          : notifier.previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text('Atrás'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: _canProceed(loginForm)
                        ? () async {
                            if (loginForm.step < 2) {
                              notifier.nextStep();
                            } else {
                              final ok = await notifier.onFormSubmit();
                              if (!context.mounted) {
                                return;
                              }

                              if (ok) {
                                context.go('/home');
                              }
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _canProceed(loginForm)
                          ? appColors.brandPrimary
                          : appColors.borderSubtle,
                    ),
                    child: loginForm.step == 2 && loginForm.isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: appColors.onBrand,
                                ),
                              ),
                              SizedBox(width: 8),
                              const Text('Ingresando...'),
                            ],
                          )
                        : Text(loginForm.step == 2 ? 'Ingresar' : 'Siguiente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedEntityLogo extends StatelessWidget {
  final String imageUrl;

  const _SelectedEntityLogo({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(6);

    if (imageUrl.isEmpty) {
      return Container(
        width: 22,
        height: 22,
        margin: const EdgeInsets.only(top: 2),
        decoration: BoxDecoration(
          color: context.appColors.surfacePrimary,
          borderRadius: borderRadius,
        ),
        child: Icon(
          Icons.business_outlined,
          size: 14,
          color: context.appColors.brandPrimary.withValues(alpha: 0.7),
        ),
      );
    }

    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: context.appColors.surfacePrimary,
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.business_outlined,
            size: 14,
            color: context.appColors.brandPrimary.withValues(alpha: 0.7),
          );
        },
      ),
    );
  }
}

AppInlineBannerVariant _authBannerVariant(AppFailureType? failureType) {
  switch (failureType) {
    case AppFailureType.sessionExpired:
      return AppInlineBannerVariant.warning;
    case AppFailureType.validationError:
      return AppInlineBannerVariant.info;
    default:
      return AppInlineBannerVariant.error;
  }
}
