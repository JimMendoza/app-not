// ignore_for_file: deprecated_member_use

import 'package:app_gore_callao/config/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_gore_callao/presentation/blocs/register/register_cubit.dart';
import 'package:app_gore_callao/presentation/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool showPassword = false;
  bool rememberMe = false;
  int step = 1;
  String user = '';
  String entity = '';
  String password = '';

  // Lista de entidades de ejemplo
  final List<Map<String, String>> entities = [
    {'id': '1', 'sig': 'GORE', 'nom': 'Gobierno Regional del Callao'},
    {'id': '2', 'sig': 'ESSALUD', 'nom': 'EsSalud Callao'},
    {'id': '3', 'sig': 'SENASA', 'nom': 'SENASA Callao'},
  ];

  @override
  Widget build(BuildContext context) {
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
              BlocProvider(
                create: (context) => RegisterCubit(),
                child: _LoginForm(
                  step: step,
                  user: user,
                  entity: entity,
                  password: password,
                  entities: entities,
                  showPassword: showPassword,
                  rememberMe: rememberMe,
                  onUserChanged: (value) {
                    setState(() {
                      user = value;
                    });
                  },
                  onEntityChanged: (value) {
                    setState(() {
                      entity = value ?? '';
                    });
                  },
                  onPasswordChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                  onTogglePassword: () {
                    setState(() {
                      showPassword = !showPassword;
                    });
                  },
                  onToggleRemember: (value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                  },
                  onStepChange: (newStep) {
                    setState(() {
                      step = newStep;
                    });
                  },
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
  final int step;
  final String user;
  final String entity;
  final String password;
  final List<Map<String, String>> entities;
  final bool showPassword;
  final bool rememberMe;
  final ValueChanged<String> onUserChanged;
  final ValueChanged<String?> onEntityChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onToggleRemember;
  final ValueChanged<int> onStepChange;

  const _LoginForm({
    required this.step,
    required this.user,
    required this.entity,
    required this.password,
    required this.entities,
    required this.showPassword,
    required this.rememberMe,
    required this.onUserChanged,
    required this.onEntityChanged,
    required this.onPasswordChanged,
    required this.onTogglePassword,
    required this.onToggleRemember,
    required this.onStepChange,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final loginForm = ref.watch(  loginFormProvider);
    final registerCubit = context.watch<RegisterCubit>();

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
                        color: step == p
                            ? const Color(0xFF99569E)
                            : step > p
                            ? const Color(0xFFEF7F7E)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$p',
                          style: GoogleFonts.montserrat(
                            color: step >= p ? Colors.white : Colors.grey[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                Text(
                  'Paso $step/3',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Paso 1: Validar Usuario
            if (step == 1) ...[
              Text(
                'Validar Usuario',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Usuario',
                hint: 'Ingrese Usuario',
                onChanged: onUserChanged,
              ),
            ],

            // Paso 2: Seleccionar Entidad
            if (step == 2) ...[
              Text(
                'Seleccionar Entidad',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: entity.isEmpty ? null : entity,
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
                onChanged: onEntityChanged,
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
                      'Usuario: $user',
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
            if (step == 3) ...[
              Text(
                'Ingresar Contraseña',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextFormField(
                label: 'Contraseña',
                hint: 'Contraseña',
                obscureText: !showPassword,
                onChanged: onPasswordChanged,
                suffixIcon: IconButton(
                  icon: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: onTogglePassword,
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
                          'Usuario: $user',
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
                          'Entidad: $entity',
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
                  Checkbox(value: rememberMe, onChanged: onToggleRemember),
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
                if (step > 1) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        onStepChange(step - 1);
                      },
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
                    onPressed: () {
                      bool canProceed = false;
                      if (step == 1 && user.isNotEmpty) canProceed = true;
                      if (step == 2 && entity.isNotEmpty) canProceed = true;
                      if (step == 3 && password.isNotEmpty) canProceed = true;

                      if (canProceed) {
                        if (step < 3) {
                          onStepChange(step + 1);
                        } else {
                          registerCubit.onSubmit();
                          // Redirigir al home
                          context.go('/home');
                        }
                      }
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          (step == 1 && user.isEmpty) ||
                              (step == 2 && entity.isEmpty) ||
                              (step == 3 && password.isEmpty)
                          ? Colors.grey[300]
                          : const Color(0xFF99569E),
                      textStyle: GoogleFonts.montserrat(),
                    ),
                    child: Text(step == 3 ? 'Ingresar' : 'Siguiente'),
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
