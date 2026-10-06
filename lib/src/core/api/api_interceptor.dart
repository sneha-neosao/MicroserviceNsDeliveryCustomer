import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nsdelivery_customer_app/src/remote/models/auth_model/token_refresh_response.dart';
import '../../configs/injector/injector.dart';
import '../session/session_manager.dart';
import '../../routes/app_route_path.dart';

class ApiInterceptor extends Interceptor {
  final Dio dio;
  bool isRefreshing = false;
  bool _isLoggingOut = false;
  final List<({void Function(String) resolve, void Function(dynamic) reject})> _requestsQueue = [];

  void _addToQueue({
    required void Function(String) resolve,
    required void Function(dynamic) reject,
  }) {
    _requestsQueue.add((resolve: resolve, reject: reject));
  }

  void _resolveQueue(String token) {
    for (final item in _requestsQueue) {
      item.resolve(token);
    }
    _requestsQueue.clear();
  }

  void _rejectQueue(dynamic error) {
    for (final item in _requestsQueue) {
      item.reject(error);
    }
    _requestsQueue.clear();
  }

  ApiInterceptor(this.dio);

  @override
  Future<void> onRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    final token = await SessionManager.getAuthToken();

    options.baseUrl = ApiUrl.baseUrl;

    bool skipAuth = options.path.contains('login') ||
        options.path.contains('/auth/otp/') ||
        options.path.contains('/token/refresh') ||
        options.path.contains('/auth/refresh');

    if (!skipAuth && token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    logger.i(
      "🔥 ApiInterceptor.onError CALLED with status: ${err.response?.statusCode} on path: ${err.requestOptions.path}",
    );

    // If refresh token request itself fails with 401, force logout
    if (err.requestOptions.path.contains('/auth/refresh')) {
      if (err.response?.statusCode == 401) {
        _logout();
      }
      return handler.next(err);
    }

    // Avoid infinite loop for auth endpoints
    if (err.requestOptions.path.contains('/auth/send-otp') ||
        err.requestOptions.path.contains('/auth/verify-otp') ||
        err.requestOptions.path.contains('/auth/signup') ||
        err.requestOptions.path.contains('/token/refresh')) {
      return handler.next(err);
    }

    // LOGOUT functionality is ONLY for 401 Unauthorized status
    if (err.response?.statusCode == 401) {
      if (_isLoggingOut) {
        return handler.next(err);
      }

      if (!isRefreshing) {
        isRefreshing = true;

        final refreshToken = await SessionManager.getRefreshToken();
        logger.i("Refresh token: $refreshToken");

        if (refreshToken == null || refreshToken.isEmpty) {
          isRefreshing = false;
          _rejectQueue(err);
          // Original request failed with 401 and no refresh token exists -> logout
          _logout();
          return handler.next(err);
        }

        try {
          // Use standalone Dio without interceptor to avoid request loops
          final refreshDio = Dio(
            BaseOptions(
              baseUrl: ApiUrl.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
            ),
          );

          final refreshResponse = await refreshDio.post(
            ApiUrl.refreshToken,
            data: {'refresh': refreshToken},
            options: Options(headers: {
              'accept': '*/*',
              'Content-Type': 'application/json',
            }),
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final parsedResponse = TokenRefreshResponse.fromJson(
              refreshResponse.data is Map<String, dynamic>
                  ? refreshResponse.data as Map<String, dynamic>
                  : null,
            );
            final newAccess = parsedResponse.data?.access;
            final newRefresh = parsedResponse.data?.refresh;
            logger.i("New access token after refresh: $newAccess");

            if (parsedResponse.success && newAccess != null && newAccess.isNotEmpty) {
              await SessionManager.updateTokens(
                accessToken: newAccess,
                refreshToken: (newRefresh != null && newRefresh.isNotEmpty)
                    ? newRefresh
                    : refreshToken,
              );

              dio.options.headers['Authorization'] = 'Bearer $newAccess';

              isRefreshing = false;
              _resolveQueue(newAccess);

              err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
              final retryResponse = await dio.fetch(err.requestOptions);
              return handler.resolve(retryResponse);
            } else {
              isRefreshing = false;
              _rejectQueue(err);
              // Not a 401 error, so do NOT logout
              return handler.next(err);
            }
          } else {
            isRefreshing = false;
            _rejectQueue(err);
            // Not a 401 error, so do NOT logout
            return handler.next(err);
          }
        } on DioException catch (dioErr) {
          logger.e("DioException during token refresh: ${dioErr.response?.statusCode}");
          isRefreshing = false;
          _rejectQueue(dioErr);
          // ONLY trigger logout if the token refresh endpoint responded with 401
          if (dioErr.response?.statusCode == 401) {
            _logout();
          }
          return handler.next(dioErr);
        } catch (e) {
          logger.e("Exception during token refresh: $e");
          isRefreshing = false;
          _rejectQueue(e);
          // Any non-Dio or other exception must NEVER trigger logout
          return handler.next(err);
        }
      } else {
        // Add to queue and wait for refresh
        try {
          final retried = await _retryRequest(err.requestOptions);
          return handler.resolve(retried);
        } catch (e) {
          if (e is DioException) {
            return handler.next(e);
          }
          return handler.next(err);
        }
      }
    }

    // For any other error (400, 403, 404, 422, 500, network issues, timeouts, etc.), NEVER logout
    return handler.next(err);
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) {
    final responseCompleter = Completer<Response>();

    _addToQueue(
      resolve: (newToken) async {
        requestOptions.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await dio.fetch(requestOptions);
          responseCompleter.complete(response);
        } catch (e) {
          responseCompleter.completeError(e);
        }
      },
      reject: (error) {
        responseCompleter.completeError(error);
      },
    );

    return responseCompleter.future;
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    logger.w("🔴 LOGOUT triggered in ApiInterceptor");

    // 1️⃣ Clear secure storage
    await SessionManager.saveLoginStatus(false);
    await SessionManager.clear();

    // 2️⃣ Clear Dio in-memory auth header
    dio.options.headers.remove('Authorization');

    // 3️⃣ Navigate to login using GoRouter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = globalNavigator.currentContext;
      logger.i("🔴 Navigation Context: $context");
      if (context == null) {
        _isLoggingOut = false;
        return;
      }

      // Close any open dialogs/bottom sheets on the root navigator
      try {
        Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      } catch (e) {
        logger.e("Error popping routes: $e");
      }

      context.goNamed(AppRoute.login.name);
      _isLoggingOut = false;
    });
  }
}
