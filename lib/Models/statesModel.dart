// To parse this JSON data, do
//
//     final statesModel = statesModelFromJson(jsonString);

import 'dart:convert';

List<StatesModel> statesModelFromJson(String str) => List<StatesModel>.from(
    json.decode(str).map((x) => StatesModel.fromJson(x)));

String statesModelToJson(List<StatesModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StatesModel {
  StatesModel({
    this.id,
    this.name,
    this.iso2,
  });

  int id;
  String name;
  String iso2;

  factory StatesModel.fromJson(Map<String, dynamic> json) => StatesModel(
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
