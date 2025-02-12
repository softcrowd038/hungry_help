// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quick_social/models/posts_model.dart';

class PostProvider with ChangeNotifier {
  PostModel _post = PostModel();
  final List<PostModel> _posts = [];
  final bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PostModel> get posts => _posts;

  int? get id => _post.id;
  String? get uuid => _post.uuid;
  String? get postUuid => _post.postUuid;
  File? get postUrl => _post.postUrl;
  String? get title => _post.title;
  String? get description => _post.description;
  DateTime? get postDate => _post.postDate;
  String? get postTime => _post.postTime;
  String? get type => _post.type;
  int? get likes => _post.likes;
  DateTime? get createdAt => _post.createdAt;

  void setId(int? value) {
    _post = _post.copyWith(id: value);
    notifyListeners();
  }

  void setUuid(String? value) {
    _post = _post.copyWith(uuid: value);
    notifyListeners();
  }

  void setPostUuid(String? value) {
    _post = _post.copyWith(postUuid: value);
    notifyListeners();
  }

  void setPostUrl(File? file) {
    _post = _post.copyWith(postUrl: file);
    notifyListeners();
  }

  void setTitle(String? value) {
    _post = _post.copyWith(title: value);
    notifyListeners();
  }

  void setDescription(String? value) {
    _post = _post.copyWith(description: value);
    notifyListeners();
  }

  void setPostDate(DateTime? value) {
    _post = _post.copyWith(postDate: value);
    notifyListeners();
  }

  void setPostTime(String? value) {
    _post = _post.copyWith(postTime: value);
    notifyListeners();
  }

  void setType(String? value) {
    _post = _post.copyWith(type: value);
    notifyListeners();
  }

  void setLikes(int? value) {
    _post = _post.copyWith(likes: value);
    notifyListeners();
  }

  void setCreatedAt(DateTime? value) {
    _post = _post.copyWith(createdAt: value);
    notifyListeners();
  }

  void resetPosts() {
    _posts.clear();

    notifyListeners();
  }
}
