import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> storeTokens(String idToken) async {
    await _storage.write(key: "idToken", value: idToken);
  }

  static Future<String?> getIdToken() async {
    return await _storage.read(key: "idToken");
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'idToken');
  }
}
