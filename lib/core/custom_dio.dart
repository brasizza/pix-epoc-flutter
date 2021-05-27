import 'package:dio/dio.dart';
import 'package:pix_epoc/core/interceptor/dio_interceptor.dart';

class CustomDio {
  static CustomDio _simpleInstance;
  Dio _dio;

  BaseOptions options = BaseOptions(
    connectTimeout: 60000,
    receiveTimeout: 60000,
  );

  CustomDio._() {
    _dio = Dio(options);
    _dio.interceptors.clear();
    _dio.interceptors.add(DioInterceptor());
  }

  static Dio get instance {
    _simpleInstance ??= CustomDio._();
    return _simpleInstance._dio;
  }
}
