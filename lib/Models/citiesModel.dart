// To parse this JSON data, do
//
//     final citiesModel = citiesModelFromJson(jsonString);

import 'dart:convert';

List<CitiesModel> citiesModelFromJson(String str) => List<CitiesModel>.from(
    json.decode(str).map((x) => CitiesModel.fromJson(x)));

String citiesModelToJson(List<CitiesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CitiesModel {
  CitiesModel({
    this.id,
    this.name,
  });

  int id;
  String name;

  factory CitiesModel.fromJson(Map<String, dynamic> json) => CitiesModel(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
