// To parse this JSON data, do
//
//     final userAccount = userAccountFromJson(jsonString);

import 'dart:convert';


UserAccount userAccountFromJson(String str) =>
    UserAccount.fromJson(json.decode(str), '');

String userAccountToJson(UserAccount data) => json.encode(data.toJson());

class UserAccount {
  String name;
  String email;
  String? uid;

  UserAccount({
    required this.name,
    required this.email,
    this.uid,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json, String uid) =>
      UserAccount(
        name: json["name"],
        email: json["email"],
        uid: uid,
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
  };
}
