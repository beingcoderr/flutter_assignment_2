import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter_assignment_2/Models/citiesModel.dart';
import 'package:flutter_assignment_2/Models/countriesModel.dart';
import 'package:flutter_assignment_2/Models/statesModel.dart';
import 'package:flutter_assignment_2/Repositories/retry_interceptor.dart';
import 'package:flutter_assignment_2/apiKeys.dart';
import 'package:get/get.dart';

import 'dio_connectivity_request_retrier.dart';

class LocationRepository {
  final dio = Dio();
  LocationRepository() {
    dio.interceptors.add(
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: dio,
          connectivity: Connectivity(),
        ),
      ),
    );
  }
  Future<List<CountriesModel>> getCountries() async {
    try {
      var _response = await dio.get(
        getCountriesUrl,
        options: Options(headers: {"X-CSCAPI-KEY": locationApiKey}),
      );
      if (_response.statusCode == 200) {
        return (_response.data as List)
            .map((e) => CountriesModel.fromJson(e))
            .toList();
      }
      return null;
    } on SocketException catch (_) {
      Get.showSnackbar(GetBar(
        message: "Unable to reach our servers",
        duration: Duration(seconds: 2),
      ));
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<StatesModel>> getStates(String country) async {
    try {
      var _response = await dio.get(
        "$getCountriesUrl$country/states",
        options: Options(headers: {"X-CSCAPI-KEY": locationApiKey}),
      );
      if (_response.statusCode == 200) {
        return (_response.data as List)
            .map((e) => StatesModel.fromJson(e))
            .toList();
      }
      return null;
    } on DioError catch (_) {
      Get.showSnackbar(GetBar(
        message: "Unable to reach our servers",
        duration: Duration(seconds: 2),
      ));
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<CitiesModel>> getCities(String state, String country) async {
    try {
      var _response = await dio.get(
        "$getCountriesUrl$country/states/$state/cities",
        options: Options(headers: {"X-CSCAPI-KEY": locationApiKey}),
      );
      if (_response.statusCode == 200) {
        return (_response.data as List)
            .map((e) => CitiesModel.fromJson(e))
            .toList();
      }
      return null;
    } on SocketException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }
}
