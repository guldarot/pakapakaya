import '../../models/domain_models.dart';
import 'secure_storage_service.dart';

class SessionStore {
  SessionStore(this._storage);

  final SecureStorageService _storage;
  String? _token;
  AppUser? _currentUser;

  String? get token => _token;
  AppUser? get currentUser => _currentUser;

  Future<void> setSession({
    required String token,
    required AppUser user,
  }) async {
    _token = token;
    _currentUser = user;
    await _storage.saveSessionToken(token);
  }

  Future<void> clear() async {
    _token = null;
    _currentUser = null;
    await _storage.clearSessionToken();
  }
}
