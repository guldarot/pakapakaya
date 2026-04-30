import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/storage/session_store.dart';
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
  AuthController(this._repository, this._sessionStore)
      : super(
          AuthState(
            user: _repository.currentUserOrNull,
            isLoading: _repository.currentUserOrNull == null,
          ),
        ) {
    _sessionStore.addListener(_handleSessionStoreChanged);
    restoreSession();
  }

  final AuthRepository _repository;
  final SessionStore _sessionStore;

  void _handleSessionStoreChanged() {
    final sessionUser = _sessionStore.currentUser;
    if (sessionUser != null) {
      state = AuthState(user: sessionUser, isLoading: false);
      return;
    }

    if (_sessionStore.sessionExpired) {
      state = const AuthState(
        user: null,
        isLoading: false,
        errorMessage: 'Your session expired. Please sign in again.',
      );
      _sessionStore.consumeSessionExpiredFlag();
      return;
    }

    if (state.user != null) {
      state = const AuthState(user: null, isLoading: false);
    }
  }

  Future<void> restoreSession() async {
    if (state.user != null) {
      state = state.copyWith(isLoading: false, clearError: true);
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.restoreSession();
      state = AuthState(user: user, isLoading: false);
    } catch (error) {
      state = AuthState(
        user: null,
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> loginDemo(UserRole role) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _repository.loginDemo(role);
      state = AuthState(user: user, isLoading: false);
    } catch (error) {
      state = AuthState(
        user: null,
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.logout();
      state = const AuthState(user: null, isLoading: false);
    } catch (error) {
      state = AuthState(
        user: state.user,
        isLoading: false,
        errorMessage: error.toString(),
      );
    }
  }

  @override
  void dispose() {
    _sessionStore.removeListener(_handleSessionStoreChanged);
    super.dispose();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionStoreProvider),
  );
});

final selectedDemoRoleProvider = StateProvider<UserRole>((ref) => UserRole.user);
