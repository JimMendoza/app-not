// ignore_for_file: deprecated_member_use

import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_gore_callao/features/shared/infrastructure/widgets/widgets.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void showSnackbar(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    final entidadesAsync = ref.watch(entidadesProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;
      showSnackbar(context, message: next.errorMessage);
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Image.asset('assets/img/logo.png', width: 200, height: 200),
                    Text(
                      Environment.appLema,
                      style: GoogleFonts.montserrat(
                        color: const Color(0xFFEF7F7E),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Formulario
              entidadesAsync.when(
                data: (entidades) =>
                    _LoginForm(loginForm: loginForm, entidades: entidades),
                loading: () => const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar entidades',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
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
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 8),
                        Text(
                          Environment.appCopyright,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: const Color(0xFF4B5563),
                          ),
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
    if (state.step == 1) return state.entity.isNotEmpty;
    if (state.step == 2) return state.username.isValid;
    if (state.step == 3) return state.password.isValid;
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(loginFormProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador de pasos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [1, 2, 3].map((p) {
                    return Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: loginForm.step == p
                            ? const Color(0xFF99569E)
                            : loginForm.step > p
                            ? const Color(0xFFEF7F7E)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$p',
                          style: GoogleFonts.montserrat(
                            color: loginForm.step >= p
                                ? Colors.white
                                : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Text(
                  'Paso ${loginForm.step}/3',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Paso 1: Seleccionar Entidad
            if (loginForm.step == 1) ...[
              const SizedBox(height: 16),
              Text(
                'Seleccione su entidad',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF99569E),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: SingleChildScrollView(
                  child: Column(
                    children: entidades.map((entidad) {
                      final isSelected =
                          loginForm.entity.isNotEmpty &&
                          loginForm.entity == entidad.siglas;
                      return GestureDetector(
                        onTap: () => notifier.onEntityChanged(entidad.siglas),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF99569E)
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: isSelected
                                ? const Color(0xFF99569E).withOpacity(0.05)
                                : Colors.white,
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
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child:
                                      entidad.imagen != null &&
                                          entidad.imagen!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            entidad.imagen!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Icon(
                                                    Icons.business,
                                                    size: 32,
                                                    color: Colors.grey[400],
                                                  );
                                                },
                                          ),
                                        )
                                      : Icon(
                                          Icons.business,
                                          size: 32,
                                          color: Colors.grey[400],
                                        ),
                                ),
                                const SizedBox(width: 16),
                                // Nombre de la entidad
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (entidad.siglas.isNotEmpty) ...[
                                        Text(
                                          entidad.siglas,
                                          style: GoogleFonts.montserrat(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF99569E),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                      Text(
                                        entidad.nombre,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          color: const Color(0xFF4B5563),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Código: ${entidad.id}',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Radio button
                                Radio<String>(
                                  value: entidad.siglas,
                                  groupValue: loginForm.entity.isEmpty
                                      ? null
                                      : loginForm.entity,
                                  activeColor: const Color(0xFF99569E),
                                  onChanged: (value) {
                                    if (value != null) {
                                      notifier.onEntityChanged(value);
                                    }
                                  },
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
            ],

            // Paso 2: Validar Usuario
            if (loginForm.step == 2) ...[
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Usuario',
                onChanged: notifier.onUsernameChanged,
                errorMessage: loginForm.username.errorMessage,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF7F7E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 14,
                      color: const Color(0xFF99569E).withOpacity(0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Entidad: ${loginForm.entity}',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: const Color(0xFF99569E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Paso 3: Ingresar Contraseña
            if (loginForm.step == 3) ...[
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Contraseña',
                obscureText: !loginForm.showPassword,
                errorMessage: loginForm.password.errorMessage,
                onChanged: notifier.onPasswordChanged,
                suffixIcon: IconButton(
                  icon: Icon(
                    loginForm.showPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: notifier.toggleShowPassword,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF7F7E).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.business_outlined,
                          size: 14,
                          color: const Color(0xFF99569E).withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Entidad: ${loginForm.entity}',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: const Color(0xFF99569E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 14,
                          color: const Color(0xFF99569E).withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Usuario: ${loginForm.username.value}',
                          style: GoogleFonts.montserrat(
                            fontSize: 13,
                            color: const Color(0xFF99569E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: loginForm.rememberMe,
                    onChanged: (value) =>
                        notifier.toggleRememberMe(value ?? false),
                  ),
                  Text(
                    'Recordarme en este dispositivo',
                    style: GoogleFonts.montserrat(),
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
                      onPressed: notifier.previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.montserrat(),
                      ),
                      child: Text('Atrás'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    onPressed: _canProceed(loginForm)
                        ? () {
                            if (loginForm.step < 3) {
                              notifier.nextStep();
                            } else {
                              notifier.onFormSubmit();
                              context.go('/home');
                            }
                          }
                        : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _canProceed(loginForm)
                          ? const Color(0xFF99569E)
                          : Colors.grey[300],
                      textStyle: GoogleFonts.montserrat(),
                    ),
                    child: Text(loginForm.step == 3 ? 'Ingresar' : 'Siguiente'),
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
