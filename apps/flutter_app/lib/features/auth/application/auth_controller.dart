import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/models.dart';
import '../../../shared/repositories/auth_repository.dart';
import '../../../shared/repositories/repository_providers.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository)
      : super(AuthState(user: _repository.currentUserOrNull));

  final AuthRepository _repository;

  Future<void> loginDemo() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.loginDemo();
      state = AuthState(user: user, isLoading: false);
    } catch (error) {
      state = AuthState(
        user: null,
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
