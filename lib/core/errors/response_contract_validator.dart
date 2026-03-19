import 'app_failure.dart';

class ResponseContractValidator {
  static AppFailure invalidResponse(String message, {Object? cause}) {
    return AppFailure(
      type: AppFailureType.serverError,
      message: message,
      cause: cause,
    );
  }

  static Map<String, dynamic> expectMap(
    dynamic value, {
    required String message,
  }) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    throw invalidResponse(message, cause: value);
  }

  static List<dynamic> expectList(dynamic value, {required String message}) {
    if (value is List<dynamic>) {
      return value;
    }

    if (value is List) {
      return List<dynamic>.from(value);
    }

    throw invalidResponse(message, cause: value);
  }

  static List<Map<String, dynamic>> expectMapList(
    List<dynamic> values, {
    required String message,
  }) {
    return values
        .map((dynamic item) => expectMap(item, message: message))
        .toList(growable: false);
  }

  static Map<String, dynamic> expectMapField(
    Map<String, dynamic> json,
    String key, {
    required String message,
  }) {
    if (!json.containsKey(key)) {
      throw invalidResponse(message, cause: json);
    }

    return expectMap(json[key], message: message);
  }

  static String expectString(
    Map<String, dynamic> json,
    String key, {
    required String message,
    bool allowEmpty = true,
  }) {
    if (!json.containsKey(key)) {
      throw invalidResponse(message, cause: json);
    }

    final dynamic value = json[key];
    if (value is! String) {
      throw invalidResponse(message, cause: value);
    }

    final String normalized = value.trim();
    if (!allowEmpty && normalized.isEmpty) {
      throw invalidResponse(message, cause: value);
    }

    return normalized;
  }

  static int expectInt(
    Map<String, dynamic> json,
    String key, {
    required String message,
  }) {
    if (!json.containsKey(key)) {
      throw invalidResponse(message, cause: json);
    }

    final dynamic value = json[key];
    if (value is int) {
      return value;
    }

    if (value is num && value == value.toInt()) {
      return value.toInt();
    }

    throw invalidResponse(message, cause: value);
  }

  static bool expectBool(
    Map<String, dynamic> json,
    String key, {
    required String message,
  }) {
    if (!json.containsKey(key)) {
      throw invalidResponse(message, cause: json);
    }

    final dynamic value = json[key];
    if (value is bool) {
      return value;
    }

    throw invalidResponse(message, cause: value);
  }

  static List<String> expectStringList(
    Map<String, dynamic> json,
    String key, {
    required String message,
  }) {
    if (!json.containsKey(key)) {
      throw invalidResponse(message, cause: json);
    }

    final dynamic value = json[key];
    if (value is! List) {
      throw invalidResponse(message, cause: value);
    }

    return value
        .map((dynamic item) {
          if (item is! String) {
            throw invalidResponse(message, cause: item);
          }

          final String normalized = item.trim();
          if (normalized.isEmpty) {
            throw invalidResponse(message, cause: item);
          }

          return normalized;
        })
        .toList(growable: false);
  }
}
