import 'package:dio/dio.dart';
import '../storage/local_storage.dart';
import 'api_exceptions.dart';

class ApiClient {
  static const String baseUrl = 'https://dummyjson.com';
  late final Dio dio;
  final LocalStorageService storage;
  bool _isRefreshing = false;

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

    // Intercepteur d authentification avec injection JWT et refresh token automatique
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          // Gestion du refresh token sur erreur 401 Unauthorized
          if (e.response?.statusCode == 401 && !_isRefreshing) {
            final refreshToken = await storage.getRefreshToken();
            if (refreshToken != null && refreshToken.isNotEmpty) {
              _isRefreshing = true;
              try {
                final refreshResponse = await Dio(
                  BaseOptions(baseUrl: baseUrl),
                ).post(
                  '/auth/refresh',
                  data: {
                    'refreshToken': refreshToken,
                    'expiresInMins': 60,
                  },
                );

                if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
                  final newAccessToken = refreshResponse.data['accessToken'] as String?;
                  final newRefreshToken = refreshResponse.data['refreshToken'] as String?;

                  if (newAccessToken != null) {
                    await storage.saveTokens(
                      token: newAccessToken,
                      refreshToken: newRefreshToken ?? refreshToken,
                    );

                    final retryOptions = e.requestOptions;
                    retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                    final retryResponse = await dio.fetch(retryOptions);
                    _isRefreshing = false;
                    return handler.resolve(retryResponse);
                  }
                }
              } catch (_) {
                await storage.clearTokens();
              } finally {
                _isRefreshing = false;
              }
            }
          }

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
