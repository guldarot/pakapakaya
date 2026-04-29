class AppConfig {
  static const bool useMockBackend =
      bool.fromEnvironment('USE_MOCK_BACKEND', defaultValue: true);

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );
}
