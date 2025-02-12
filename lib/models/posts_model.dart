import 'dart:io';

class PostModel {
  final int? id;
  final String? uuid;
  final String? postUuid;
  final File? postUrl;
  final String? title;
  final String? description;
  final DateTime? postDate;
  final String? postTime;
  final String? type;
  final int? likes;
  final DateTime? createdAt;

  PostModel({
    this.id,
    this.uuid,
    this.postUuid,
    this.postUrl,
    this.title,
    this.description,
    this.postDate,
    this.postTime,
    this.type,
    this.likes,
    this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      uuid: json['uuid'],
      postUuid: json['post_uuid'],
      postUrl: json['post_url'],
      title: json['title'],
      description: json['description'],
      postDate:
          json['post_date'] != null ? DateTime.parse(json['post_date']) : null,
      postTime: json['post_time'],
      type: json['type'],
      likes: json['likes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  PostModel copyWith({
    int? id,
    String? uuid,
    String? postUuid,
    File? postUrl,
    String? title,
    String? description,
    DateTime? postDate,
    String? postTime,
    String? type,
    int? likes,
    DateTime? createdAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      postUuid: postUuid ?? this.postUuid,
      postUrl: postUrl ?? this.postUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      postDate: postDate ?? this.postDate,
      postTime: postTime ?? this.postTime,
      type: type ?? this.type,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
