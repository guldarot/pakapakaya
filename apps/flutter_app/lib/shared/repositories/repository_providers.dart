import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_config.dart';
import '../../mocks/mock_backend.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';
import '../storage/session_store.dart';
import 'auth_repository.dart';
import 'chat_repository.dart';
import 'http_repositories.dart';
import 'marketplace_repository.dart';
import 'mock_repositories.dart';

final backendProvider = Provider<MockBackend>((ref) => MockBackend.instance);

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SessionStore(ref.watch(secureStorageServiceProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final sessionStore = ref.watch(sessionStoreProvider);
  return ApiClient(
    baseUrl: AppConfig.apiBaseUrl,
    tokenReader: () => sessionStore.token,
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (!AppConfig.useMockBackend) {
    return HttpAuthRepository(
      ref.watch(apiClientProvider),
      ref.watch(sessionStoreProvider),
    );
  }
  return MockAuthRepository(ref.watch(backendProvider));
});

final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  if (!AppConfig.useMockBackend) {
    return HttpMarketplaceRepository(ref.watch(apiClientProvider));
  }
  return MockMarketplaceRepository(ref.watch(backendProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  if (!AppConfig.useMockBackend) {
    return HttpChatRepository(ref.watch(apiClientProvider));
  }
  return MockChatRepository(ref.watch(backendProvider));
});
