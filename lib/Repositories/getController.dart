import 'package:flutter_assignment_2/Models/citiesModel.dart';
import 'package:get/get.dart';

class Controller extends GetxController {
  RxList<String> addedCities = RxList<String>();
  var futureCities = Future.value(List<CitiesModel>()).obs;

  void addCity(String city) {
    addedCities.add(city);
  }

  void removeCity(String city) {
    addedCities.remove(city);
  }
}
