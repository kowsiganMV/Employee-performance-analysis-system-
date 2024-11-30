// To parse this JSON data, do
//
//     final mongoDbModel = mongoDbModelFromJson(jsonString);

import 'dart:convert';


MongoDbModel mongoDbModelFromJson(String str) => MongoDbModel.fromJson(json.decode(str));

String mongoDbModelToJson(MongoDbModel data) => json.encode(data.toJson());

class MongoDbModel {
    String id;
    String name;
    String position;
    String head;
    String image;

    MongoDbModel({
        required this.id,
        required this.name,
        required this.position,
        required this.head,
        required this.image,
    });

    factory MongoDbModel.fromJson(Map<String, dynamic> json) => MongoDbModel(
        id: json["id"],
        name: json["name"],
        position: json["position"],
        head: json["head"],
        image: json["image"]
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "position": position,
        "head": head,
        "image":image
    };
}
