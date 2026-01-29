import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static initEnvironment() async {
    await dotenv.load(fileName: '.env');
  }

  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'No está configurado el APP_NAME';
  static String get appLema =>
      dotenv.env['APP_LEMA'] ?? 'No está configurado el APP_LEMA';
  static String get appCopyright =>
      dotenv.env['APP_COPYRIGHT'] ?? 'No está configurado el APP_COPYRIGHT';
  static String get apiUrl =>
      dotenv.env['API_URL'] ?? 'No está configurado el API_URL';
}
