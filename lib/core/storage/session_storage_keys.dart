class SessionStorageKeys {
  static const String accessToken = 'access_token';
  static const String tokenType = 'token_type';
  static const String rememberSession = 'remember_session';
  static const String selectedEntityName = 'selected_entity_name';
  static const String selectedEntityImage = 'selected_entity_image';
  static const String dataPolicyAcceptancePrefix =
      'data_policy_acceptance_user_';
  static const String dataPolicyVersion = 'v1';

  static const List<String> authKeys = <String>[
    accessToken,
    tokenType,
    rememberSession,
    selectedEntityName,
    selectedEntityImage,
  ];

  static String dataPolicyAcceptanceKey(String username) {
    final String normalizedUsername = username
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]+'), '_');

    return '$dataPolicyAcceptancePrefix$normalizedUsername';
  }
}
