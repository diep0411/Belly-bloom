// To parse this JSON data, do

//     final userAccount = userAccountFromJson(jsonString);

import 'dart:convert';

import 'package:my_project/model/form_collection.dart';

UserAccount userAccountFromJson(String str) =>
    UserAccount.fromJson(json.decode(str), '');

String userAccountToJson(UserAccount data) => json.encode(data.toJson());

class UserAccount {
  String name;
  String email;
  FormCollection? formCollection;
  String? uid;

  UserAccount({
    required this.name,
    required this.email,
    this.formCollection,
    this.uid,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json, String uid) =>
      UserAccount(
        name: json["name"],
        email: json["email"],
        uid: uid,
        formCollection:
            json["formCollection"] != null
                ? FormCollection.fromJson(json["formCollection"])
                : null,
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "formCollection": formCollection?.toJson(),
  };
  UserAccount copyWith({FormCollection? formCollection}) => UserAccount(
    name: name,
    email: email,
    uid: uid,
    formCollection: formCollection ?? this.formCollection,
  );
}
