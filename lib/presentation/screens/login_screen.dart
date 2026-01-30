// ignore_for_file: deprecated_member_use

import 'package:app_gore_callao/config/config.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/login_form_provider.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_gore_callao/presentation/widgets/widgets.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  // Lista de entidades de ejemplo
  static const List<Map<String, String>> entities = [
    {'id': '1', 'sig': 'GORE', 'nom': 'Gobierno Regional del Callao'},
    {'id': '2', 'sig': 'ESSALUD', 'nom': 'EsSalud Callao'},
    {'id': '3', 'sig': 'SENASA', 'nom': 'SENASA Callao'},
  ];

  void showSnackbar(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);

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
              _LoginForm(loginForm: loginForm, entities: entities),

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
  final List<Map<String, String>> entities;

  const _LoginForm({required this.loginForm, required this.entities});

  bool _canProceed(LoginFormState state) {
    if (state.step == 1) return state.username.isValid;
    if (state.step == 2) return state.entity.isNotEmpty;
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

            // Paso 1: Validar Usuario
            if (loginForm.step == 1) ...[
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Usuario',
                onChanged: notifier.onUsernameChanged,
                errorMessage: loginForm.username.errorMessage,
              ),
            ],

            // Paso 2: Seleccionar Entidad
            if (loginForm.step == 2) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: loginForm.entity.isEmpty ? null : loginForm.entity,
                decoration: InputDecoration(
                  labelText: 'Entidad',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  isDense: true,
                ),
                items: entities.map((e) {
                  return DropdownMenuItem<String>(
                    value: e['sig'],
                    child: Text(e['nom']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) notifier.onEntityChanged(value);
                },
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
                    const SizedBox(height: 4),
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
