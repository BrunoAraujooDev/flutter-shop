import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConfigEnv {
  static String get key => _get('KEY_REALTIME');

  static String _get(String name) => dotenv.env[name] ?? '';
}
