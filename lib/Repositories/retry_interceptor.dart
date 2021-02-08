import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

import 'dio_connectivity_request_retrier.dart';

class RetryOnConnectionChangeInterceptor extends Interceptor {
  final DioConnectivityRequestRetrier requestRetrier;

  RetryOnConnectionChangeInterceptor({
    this.requestRetrier,
  });

  @override
  Future onError(DioError err) async {
    if (_shouldRetry(err)) {
      try {
        Get.showSnackbar(GetBar(
          message: "Unable to reach our servers",
          duration: Duration(seconds: 2),
        ));

        return requestRetrier.scheduleRequestRetry(err.request);
      } catch (e) {
        // Let any new error from the retrier pass through
        return e;
      }
    }
    // Let the error pass through if it's not the error we're looking for
    return err;
  }

  bool _shouldRetry(DioError err) {
    return err.type == DioErrorType.DEFAULT &&
        err.error != null &&
        err.error is SocketException;
  }
}
