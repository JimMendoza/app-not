import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/shared.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';

final StateNotifierProvider<LoginFormNotifier, LoginFormState>
loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
      final Future<User> Function(String, String, String) loginCallback = ref
          .watch(authProvider.notifier)
          .login;
      final AuthNotifier authNotifier = ref.watch(authProvider.notifier);
      final AsyncValue<List<Entidad>> entidades = ref.watch(entidadesProvider);

      return LoginFormNotifier(
        loginCallback: loginCallback,
        authNotifier: authNotifier,
        entidades: entidades,
      );
    });

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Future<User> Function(String, String, String) loginCallback;
  final AuthNotifier authNotifier;
  final AsyncValue<List<Entidad>> entidades;

  LoginFormNotifier({
    required this.loginCallback,
    required this.authNotifier,
    required this.entidades,
  }) : super(LoginFormState());

  void onUsernameChanged(String value) {
    final newUsername = Username.dirty(value);
    state = state.copyWith(
      username: newUsername,
      isValid: Formz.validate([newUsername]),
    );
  }

  void onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([state.username, newPassword]),
    );
  }

  void onEntityChanged(String value, String codEntidad) {
    state = state.copyWith(entity: value, codEntidad: codEntidad);
  }

  void toggleShowPassword() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  void setStep(int step) {
    state = state.copyWith(step: step);
  }

  void nextStep() {
    if (state.step < 2) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  void previousStep() {
    if (state.step > 1) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  bool canProceed() {
    if (state.step == 1) {
      return state.entity.isNotEmpty;
    }

    if (state.step == 2) {
      return state.username.isValid && state.password.isValid;
    }

    return false;
  }

  Future<bool> onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid) {
      return false;
    }

    try {
      await loginCallback(
        state.username.value,
        state.password.value,
        state.codEntidad,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void _touchEveryField() {
    final username = Username.dirty(state.username.value);
    final password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      username: username,
      password: password,
      isValid: Formz.validate([username, password]),
    );
  }
}

class LoginFormState {
  final bool isPosting;
  final bool isFormPosted;
  final bool isValid;
  final Username username;
  final String codEntidad;
  final Password password;
  final int step;
  final bool showPassword;
  final bool rememberMe;
  final String entity;

  LoginFormState({
    this.username = const Username.pure(),
    this.codEntidad = '',
    this.password = const Password.pure(),
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.step = 1,
    this.showPassword = false,
    this.rememberMe = false,
    this.entity = '',
  });

  LoginFormState copyWith({
    Username? username,
    String? codEntidad,
    Password? password,
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    int? step,
    bool? showPassword,
    bool? rememberMe,
    String? entity,
    User? validatedUser,
  }) {
    return LoginFormState(
      username: username ?? this.username,
      codEntidad: codEntidad ?? this.codEntidad,
      password: password ?? this.password,
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      step: step ?? this.step,
      showPassword: showPassword ?? this.showPassword,
      rememberMe: rememberMe ?? this.rememberMe,
      entity: entity ?? this.entity,
    );
  }

  @override
  String toString() {
    return '''
LoginFormState:
      username: $username,
      codEntidad: $codEntidad,
      password: $password,
      isPosting: $isPosting,
      isFormPosted: $isFormPosted,
      isValid: $isValid,
      step: $step,
      entity: $entity,
      showPassword: $showPassword,
      rememberMe: $rememberMe,
    ''';
  }
}
