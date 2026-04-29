import '../../models/models.dart';

abstract class AuthRepository {
  AppUser? get currentUserOrNull;

  Future<AppUser> loginDemo();
}
