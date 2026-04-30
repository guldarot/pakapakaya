import 'package:dio/dio.dart';

class ApiClientException implements Exception {
  ApiClientException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    Dio? dio,
    this.baseUrl = 'https://api.pakapakaya.example',
    String? Function()? tokenReader,
    Future<void> Function()? onUnauthorized,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = tokenReader?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && onUnauthorized != null) {
            await onUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final String baseUrl;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _wrap(() => _dio.get('$baseUrl$path', queryParameters: queryParameters));
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _wrap(() => _dio.post(
      '$baseUrl$path',
      data: data,
      queryParameters: queryParameters,
    ));
  }

  Future<Response<dynamic>> patch(String path, {Object? data}) {
    return _wrap(() => _dio.patch('$baseUrl$path', data: data));
  }

  Future<Response<dynamic>> postWithoutBody(String path) {
    return _wrap(() => _dio.post('$baseUrl$path'));
  }

  Future<Response<dynamic>> _wrap(Future<Response<dynamic>> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;
      final message = switch (data) {
        {'error': final String value} => value,
        _ when statusCode == 401 => 'Your session expired. Please sign in again.',
        _ when statusCode == 403 => 'You do not have access to do that.',
        _ when statusCode != null => 'Request failed with status $statusCode.',
        _ => 'Could not reach the server. Please try again.',
      };
      throw ApiClientException(message, statusCode: statusCode);
    }
  }
}
