// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

WelcomeModel welcomeFromJson(String str) =>
    WelcomeModel.fromJson(json.decode(str));

String welcomeToJson(WelcomeModel data) => json.encode(data.toJson());

class WelcomeModel {
  String title;
  String imageUrl;
  String? subtitle;
  String content;

  WelcomeModel({
    required this.title,
    required this.imageUrl,
    this.subtitle,
    required this.content,
  });

  factory WelcomeModel.fromJson(Map<String, dynamic> json) => WelcomeModel(
    title: json["title"],
    imageUrl: json["ImageUrl"],
    subtitle: json["subtitle"],
    content: json["content"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "ImageUrl": imageUrl,
    "subtitle": subtitle,
    "content": content,
  };
}
