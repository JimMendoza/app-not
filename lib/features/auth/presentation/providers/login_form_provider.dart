import 'package:app_gore_callao/features/auth/domain/domain.dart';
import 'package:app_gore_callao/features/auth/presentation/providers/providers.dart';
import 'package:app_gore_callao/features/shared/shared.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:formz/formz.dart';

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
      final validarUsuarioCallback = ref
          .watch(authProvider.notifier)
          .validarUsuario;
      return LoginFormNotifier(validarUsuarioCallback: validarUsuarioCallback);
    });

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Future<User> Function(String) validarUsuarioCallback;
  LoginFormNotifier({required this.validarUsuarioCallback})
    : super(LoginFormState());

  onUsernameChanged(String value) {
    final newUsername = Username.dirty(value);
    state = state.copyWith(
      username: newUsername,
      isValid: Formz.validate([newUsername]),
    );
  }

  onEntityChanged(String value) {
    state = state.copyWith(entity: value);
  }

  onPasswordChanged(String value) {
    final newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([state.username, newPassword]),
    );
  }

  toggleShowPassword() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  setStep(int step) {
    state = state.copyWith(step: step);
  }

  nextStep() async {
    if (state.step < 3) {
      if (state.step == 1) {
        try {
          state = state.copyWith(isPosting: true);
          final user = await validarUsuarioCallback(state.username.value);
          state = state.copyWith(
            isPosting: false,
            step: state.step + 1,
            validatedUser: user,
          );
        } catch (e) {
          state = state.copyWith(isPosting: false, validatedUser: null);
        }
      } else {
        state = state.copyWith(step: state.step + 1);
      }
    }
  }

  previousStep() {
    if (state.step > 1) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  bool canProceed() {
    if (state.step == 1) return state.username.isValid;
    if (state.step == 2) return state.entity.isNotEmpty;
    if (state.step == 3) return state.password.isValid;
    return false;
  }

  onFormSubmit() {
    _touchEveryField();

    if (!state.isValid) return;

    print(state);
  }

  _touchEveryField() {
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
  final Entidad codEntidad;
  final Password password;
  final int step;
  final bool showPassword;
  final bool rememberMe;
  final String entity;
  final User? validatedUser;

  LoginFormState({
    this.isPosting = false,
    this.isFormPosted = false,
    this.isValid = false,
    this.username = const Username.pure(),
    this.codEntidad = const Entidad.pure(),
    this.password = const Password.pure(),
    this.step = 1,
    this.showPassword = false,
    this.rememberMe = false,
    this.entity = '',
    this.validatedUser,
  });

  LoginFormState copyWith({
    bool? isPosting,
    bool? isFormPosted,
    bool? isValid,
    Username? username,
    Entidad? codEntidad,
    Password? password,
    int? step,
    bool? showPassword,
    bool? rememberMe,
    String? entity,
    User? validatedUser,
  }) {
    return LoginFormState(
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      username: username ?? this.username,
      codEntidad: codEntidad ?? this.codEntidad,
      password: password ?? this.password,
      step: step ?? this.step,
      showPassword: showPassword ?? this.showPassword,
      rememberMe: rememberMe ?? this.rememberMe,
      entity: entity ?? this.entity,
      validatedUser: validatedUser ?? this.validatedUser,
    );
  }

  @override
  String toString() {
    return '''
LoginFormState:
      isPosting: $isPosting,
      isFormPosted: $isFormPosted,
      isValid: $isValid,
      username: $username,
      codEntidad: $codEntidad,
      password: $password,
      step: $step,
      entity: $entity,
      showPassword: $showPassword,
      rememberMe: $rememberMe,
      validatedUser: $validatedUser,
    ''';
  }
}
