import 'package:dio/dio.dart';

class ApiClient {
  ApiClient({
    Dio? dio,
    this.baseUrl = 'https://api.pakapakaya.example',
    String? Function()? tokenReader,
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
      ),
    );
  }

  final Dio _dio;
  final String baseUrl;

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get('$baseUrl$path', queryParameters: queryParameters);
  }

  Future<Response<dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.post(
      '$baseUrl$path',
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<Response<dynamic>> patch(String path, {Object? data}) {
    return _dio.patch('$baseUrl$path', data: data);
  }
}
