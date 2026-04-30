import '../../models/models.dart';

abstract class AuthRepository {
  AppUser? get currentUserOrNull;

  Future<AppUser?> restoreSession();
  Future<AppUser> loginDemo(UserRole role);
  Future<void> logout();
}
