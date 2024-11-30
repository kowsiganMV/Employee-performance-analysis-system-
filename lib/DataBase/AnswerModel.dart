// To parse this JSON data, do
//
//     final answersmodel = answersmodelFromJson(jsonString);

import 'dart:convert';

Answersmodel answersmodelFromJson(String str) => Answersmodel.fromJson(json.decode(str));

String answersmodelToJson(Answersmodel data) => json.encode(data.toJson());

class Answersmodel {
    String id;
    String answers;
    DateTime date; 
    String total;
    String position;

    Answersmodel({
        required this.id,
        required this.answers,
        required this.date,
        required this.total,
        required this.position,
    });

    factory Answersmodel.fromJson(Map<String, dynamic> json) => Answersmodel(
        id: json["id"],
        answers: json["answers"],
        date: json["date"],
        total: json["total"],
        position: json["position"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "answers": answers,
        "date": date,
        "total": total,
        "position": position,
    };
}
