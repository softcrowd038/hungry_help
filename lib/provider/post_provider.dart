import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quick_social/models/posts_model.dart';

class PostProvider with ChangeNotifier {
  PostModel _post = PostModel(
    uuid: '',
    postUuid: '',
    title: '',
    description: '',
    postDate: '',
    postTime: '',
    type: '',
    likes: 0,
    postUrl: null,
  );

  // Getters
  String get uuid => _post.uuid;
  String get postUuid => _post.postUuid;
  String get title => _post.title;
  String get description => _post.description;
  String get postDate => _post.postDate;
  String get postTime => _post.postTime;
  String get type => _post.type;
  int get likes => _post.likes;
  File? get postUrl => _post.postUrl;

  setUuid(String value) {
    _post.uuid = value;
    notifyListeners();
  }

  setPostUuid(String value) {
    _post.postUuid = value;
    notifyListeners();
  }

  setTitle(String value) {
    _post.title = value;
    notifyListeners();
  }

  setDescription(String value) {
    _post.description = value;
    notifyListeners();
  }

  setPostDate(String value) {
    _post.postDate = value;
    notifyListeners();
  }

  setPostTime(String value) {
    _post.postTime = value;
    notifyListeners();
  }

  setType(String value) {
    _post.type = value;
    notifyListeners();
  }

  setLikes(int value) {
    _post.likes = value;
    notifyListeners();
  }

  void setPostUrl(File file) {
    _post.postUrl = file;
    notifyListeners();
  }

  void resetPost() {
    _post = PostModel(
      uuid: '',
      postUuid: '',
      title: '',
      description: '',
      postDate: '',
      postTime: '',
      type: '',
      likes: 0,
      postUrl: null,
    );
    notifyListeners();
  }
}
