import 'package:dio/dio.dart';
import '../storage/local_storage.dart';
import 'api_exceptions.dart';

class ApiClient {
  static const String baseUrl = 'https://dummyjson.com';
  late final Dio dio;
  final LocalStorageService storage;

  ApiClient({required this.storage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Intercepteur pour l injection automatique du token JWT
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ' + token;
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: const NetworkException(),
              ),
            );
          } else if (e.response?.statusCode == 401) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: const UnauthorizedException(),
              ),
            );
          } else if ((e.response?.statusCode ?? 0) >= 500) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: const ServerException(),
              ),
            );
          }
          return handler.next(e);
        },
      ),
    );
  }
}
