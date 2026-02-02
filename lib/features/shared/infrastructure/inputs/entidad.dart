import 'package:formz/formz.dart';

// Define input validation errors
enum EntidadError { empty }

// Extend FormzInput and provide the input type and error type.
class EntidadV extends FormzInput<String, EntidadError> {
  // Call super.pure to represent an unmodified form input.
  const EntidadV.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const EntidadV.dirty(String value) : super.dirty(value);

  String? get errorMessage {
    if (isValid || isPure) return null;

    if (displayError == EntidadError.empty) return 'El campo es requerido';
    return null;
  }

  // Override validator to handle validating a given input value.
  @override
  EntidadError? validator(String value) {
    if (value.isEmpty || value.trim().isEmpty) return EntidadError.empty;

    return null;
  }
}
