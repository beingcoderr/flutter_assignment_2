// To parse this JSON data, do
//
//     final countriesModel = countriesModelFromJson(jsonString);

import 'dart:convert';

List<CountriesModel> countriesModelFromJson(String str) =>
    List<CountriesModel>.from(
        json.decode(str).map((x) => CountriesModel.fromJson(x)));

String countriesModelToJson(List<CountriesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CountriesModel {
  CountriesModel({
    this.id,
    this.name,
    this.iso2,
  });

  int id;
  String name;
  String iso2;

  factory CountriesModel.fromJson(Map<String, dynamic> json) => CountriesModel(
        id: json["id"],
        name: json["name"],
        iso2: json["iso2"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "iso2": iso2,
      };
}
