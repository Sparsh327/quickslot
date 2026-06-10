import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

import '../../../core/error/failure.dart';
import '../../../core/services/user_session.dart';
import '../../../values/network_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient(UserSession session) {
    _dio = Dio(BaseOptions(
      baseUrl: NetworkConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.addAll([
      TalkerDioLogger(),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final uid = session.userId;
          if (uid != null) options.headers['X-User-Id'] = uid;
          handler.next(options);
        },
      ),
    ]);
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<Response<dynamic>> post(String path, {dynamic data}) async {
    try {
      return await _dio.post(path, data: data);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Future<Response<dynamic>> delete(String path) async {
    try {
      return await _dio.delete(path);
    } on DioException catch (e) {
      throw _toFailure(e);
    }
  }

  Failure _toFailure(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    final code = e.response?.statusCode;
    final msg =
        e.response?.data?['error'] as String? ?? e.message ?? 'Unknown error';
    if (code == 401) return UnauthorizedFailure(msg);
    if (code == 409) return ConflictFailure(msg);
    return ServerFailure(msg);
  }
}
