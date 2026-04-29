import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _sessionKey = 'session_token';

  Future<void> saveSessionToken(String token) {
    return _storage.write(key: _sessionKey, value: token);
  }

  Future<String?> readSessionToken() {
    return _storage.read(key: _sessionKey);
  }

  Future<void> clearSessionToken() {
    return _storage.delete(key: _sessionKey);
  }
}
