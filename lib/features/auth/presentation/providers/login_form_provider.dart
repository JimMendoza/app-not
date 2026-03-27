import 'package:app_not/features/auth/domain/domain.dart';
import 'package:app_not/features/auth/infrastructure/inputs/inputs.dart';
import 'package:app_not/features/auth/presentation/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

final loginFormProvider =
    NotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>(
      LoginFormNotifier.new,
    );

class LoginFormNotifier extends Notifier<LoginFormState> {
  Future<User> Function(String, String, String, bool) get _loginCallback =>
      ref.read(authProvider.notifier).login;

  AuthNotifier get _authNotifier => ref.read(authProvider.notifier);

  @override
  LoginFormState build() {
    return LoginFormState();
  }

  void onUsernameChanged(String value) {
    final Username newUsername = Username.dirty(value);
    state = state.copyWith(
      username: newUsername,
      isValid: Formz.validate([newUsername]),
    );
  }

  void onPasswordChanged(String value) {
    final Password newPassword = Password.dirty(value);
    state = state.copyWith(
      password: newPassword,
      isValid: Formz.validate([state.username, newPassword]),
    );
  }

  void onEntityChanged(String value, String codEntidad, String entityImage) {
    state = state.copyWith(
      entity: value,
      codEntidad: codEntidad,
      entityImage: entityImage,
    );
  }

  void toggleShowPassword() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void toggleRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  void setStep(int step) {
    if (step < 1 || step > 2 || step == state.step) {
      return;
    }

    _changeStep(step);
  }

  void nextStep() {
    if (state.step < 2) {
      _changeStep(state.step + 1);
    }
  }

  void previousStep() {
    if (state.step > 1) {
      _changeStep(state.step - 1);
    }
  }

  Future<bool> onFormSubmit() async {
    _touchEveryField();

    if (!state.isValid || state.isSubmitting) {
      return false;
    }

    state = state.copyWith(isSubmitting: true);

    try {
      await _loginCallback(
        state.username.value,
        state.password.value,
        state.codEntidad,
        state.rememberMe,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  void _touchEveryField() {
    final Username username = Username.dirty(state.username.value);
    final Password password = Password.dirty(state.password.value);

    state = state.copyWith(
      isFormPosted: true,
      username: username,
      password: password,
      isValid: Formz.validate([username, password]),
    );
  }

  void _changeStep(int step) {
    final Username username = Username.pure(state.username.value);
    final Password password = Password.pure(state.password.value);

    state = state.copyWith(
      step: step,
      isFormPosted: false,
      username: username,
      password: password,
      isValid: Formz.validate([username, password]),
    );

    _authNotifier.clearErrorMessage();
  }
}

class LoginFormState {
  final bool isFormPosted;
  final bool isValid;
  final bool isSubmitting;
  final Username username;
  final String codEntidad;
  final Password password;
  final int step;
  final bool showPassword;
  final bool rememberMe;
  final String entity;
  final String entityImage;

  LoginFormState({
    this.username = const Username.pure(),
    this.codEntidad = '',
    this.password = const Password.pure(),
    this.isFormPosted = false,
    this.isValid = false,
    this.isSubmitting = false,
    this.step = 1,
    this.showPassword = false,
    this.rememberMe = false,
    this.entity = '',
    this.entityImage = '',
  });

  LoginFormState copyWith({
    Username? username,
    String? codEntidad,
    Password? password,
    bool? isFormPosted,
    bool? isValid,
    bool? isSubmitting,
    int? step,
    bool? showPassword,
    bool? rememberMe,
    String? entity,
    String? entityImage,
  }) {
    return LoginFormState(
      username: username ?? this.username,
      codEntidad: codEntidad ?? this.codEntidad,
      password: password ?? this.password,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      step: step ?? this.step,
      showPassword: showPassword ?? this.showPassword,
      rememberMe: rememberMe ?? this.rememberMe,
      entity: entity ?? this.entity,
      entityImage: entityImage ?? this.entityImage,
    );
  }

  @override
  String toString() {
    return '''
LoginFormState:
      username: $username,
      codEntidad: $codEntidad,
      password: $password,
      isFormPosted: $isFormPosted,
      isValid: $isValid,
      isSubmitting: $isSubmitting,
      step: $step,
      entity: $entity,
      entityImage: $entityImage,
      showPassword: $showPassword,
      rememberMe: $rememberMe,
    ''';
  }
}
