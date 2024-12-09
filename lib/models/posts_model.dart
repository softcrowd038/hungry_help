import 'dart:io';

class PostModel {
  String uuid;
  String postUuid;
  String title;
  String description;
  String postDate;
  String postTime;
  String type;
  int likes;
  File? postUrl;

  PostModel({
    required this.uuid,
    required this.postUuid,
    required this.title,
    required this.description,
    required this.postDate,
    required this.postTime,
    required this.type,
    this.likes = 0,
    this.postUrl,
  });
}
