import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static final storage = const FlutterSecureStorage();

  static Future<String?> get(String key) async {
    return await storage.read(key: key);
  }

  static Future<bool> store(String key, String value) async {
    await storage.write(key: key, value: value);
    return true;
  }

  static Future<bool> remove(String key) async {
    await storage.delete(key: key);
    return true;
  }
}
