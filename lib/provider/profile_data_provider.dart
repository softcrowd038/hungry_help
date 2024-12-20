// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';

class UserProfileProvider with ChangeNotifier {
  String _uuid = '';
  File? _imageUrl;
  String _username = '';
  String _firstname = '';
  String _lastname = '';
  String _location = '';
  double _latitude = 0.0;
  double _longitude = 0.0;
  String _birthdate = '';
  String _status = '';

  String get uuid => _uuid;
  File? get imageUrl => _imageUrl;
  String get username => _username;
  String get firstname => _firstname;
  String get lastname => _lastname;
  String get location => _location;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get birthdate => _birthdate;
  String get status => _status;

  void setUuid(String value) {
    _uuid = value;
    notifyListeners();
  }

  void setProfileImage(File value) {
    _imageUrl = value;
    notifyListeners();
  }

  void setUsername(String value) {
    _username = value;
    notifyListeners();
  }

  void setFirstname(String value) {
    _firstname = value;
    notifyListeners();
  }

  void setLastname(String value) {
    _lastname = value;
    notifyListeners();
  }

  void setLocation(String value) {
    _location = value;
    notifyListeners();
  }

  void setLatitude(double value) {
    _latitude = value;
    notifyListeners();
  }

  void setLongitude(double value) {
    _longitude = value;
    notifyListeners();
  }

  void setBirthdate(String value) {
    _birthdate = value;
    notifyListeners();
  }

  void setStatus(String value) {
    _status = value;
    notifyListeners();
  }

  void updateProfile({
    required String uuid,
    required File? imageUrl,
    required String username,
    required String firstname,
    required String lastname,
    required String location,
    required double latitude,
    required double longitude,
    required String birthdate,
    required String status,
  }) {
    _uuid = uuid;
    _imageUrl = imageUrl;
    _username = username;
    _firstname = firstname;
    _lastname = lastname;
    _location = location;
    _latitude = latitude;
    _longitude = longitude;
    _birthdate = birthdate;
    _status = status;
    notifyListeners();
  }
}
