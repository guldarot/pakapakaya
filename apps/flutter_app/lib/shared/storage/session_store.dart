import 'package:flutter/foundation.dart';

import '../../models/domain_models.dart';
import 'secure_storage_service.dart';

class SessionStore extends ChangeNotifier {
  SessionStore(this._storage);

  final SecureStorageService _storage;
  String? _token;
  AppUser? _currentUser;
  bool _sessionExpired = false;

  String? get token => _token;
  AppUser? get currentUser => _currentUser;
  bool get sessionExpired => _sessionExpired;

  Future<String?> restoreToken() async {
    _token = await _storage.readSessionToken();
    notifyListeners();
    return _token;
  }

  Future<void> setSession({
    required String token,
    required AppUser user,
  }) async {
    _token = token;
    _currentUser = user;
    _sessionExpired = false;
    await _storage.saveSessionToken(token);
    notifyListeners();
  }

  Future<void> clear() async {
    _token = null;
    _currentUser = null;
    _sessionExpired = false;
    await _storage.clearSessionToken();
    notifyListeners();
  }

  Future<void> expireSession() async {
    _token = null;
    _currentUser = null;
    _sessionExpired = true;
    await _storage.clearSessionToken();
    notifyListeners();
  }

  void consumeSessionExpiredFlag() {
    if (!_sessionExpired) {
      return;
    }
    _sessionExpired = false;
    notifyListeners();
  }
}
