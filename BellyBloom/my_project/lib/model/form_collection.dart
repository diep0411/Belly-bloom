import 'package:cloud_firestore/cloud_firestore.dart';

class FormCollection {
  int id;
  double height;
  int weight;
  int week;
  DateTime createdAt;
  DateTime lastestUpdate;

  FormCollection({
    required this.id,
    required this.height,
    required this.weight,
    required this.week,
    required this.createdAt,
    required this.lastestUpdate,
  });

  factory FormCollection.fromJson(Map<String, dynamic> json) {
    Timestamp ts = json['createdAt'];
    Timestamp tsLastestUpdate = json['lastestUpdate'];
    DateTime createdAt = ts.toDate();
    DateTime lastestUpdate = tsLastestUpdate.toDate();
    return FormCollection(
      id: json['id'],
      height: json['height'].toDouble(),
      weight: json['weight'],
      week: json['week'],
      createdAt: createdAt,
      lastestUpdate: lastestUpdate,
    );
  }
  // Timestamp ts = json['createdAt'];
  // Timestamp tsLastestUpdate = json['lastestUpdate'];
  // DateTime createdAt = ts.toDate();
  // DateTime lastestUpdate = tsLastestUpdate.toDate();

  Map<String, dynamic> toJson() => {
    "id": id,
    "height": height,
    "weight": weight,
    "week": week,
    "createdAt": createdAt,
    "lastestUpdate": lastestUpdate,
    
  };
}
