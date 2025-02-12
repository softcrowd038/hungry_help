import 'dart:io';
import 'package:flutter/material.dart';

class InformerDataProvider extends ChangeNotifier {
  String _uuid = '';
  File? _imageurl;
  String _description = '';
  String _donationDate = '';
  String _donationTime = '';
  String _quantity = '';
  String _location = '';
  double _latitude = 0.0;
  double _longitude = 0.0;

  String get uuid => _uuid;
  File? get imageurl => _imageurl;
  String get description => _description;
  String get donationDate => _donationDate;
  String get donationTime => _donationTime;
  String get quantity => _quantity;
  String get location => _location;
  double get latitude => _latitude;
  double get longitude => _longitude;

  void setUuid(String value) {
    _uuid = value;
    notifyListeners();
  }

  void setImageUrl(File? value) {
    _imageurl = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setDonationDate(String value) {
    _donationDate = value;
    notifyListeners();
  }

  void setDonationTime(String value) {
    _donationTime = value;
    notifyListeners();
  }

  void setQuantity(String value) {
    _quantity = value;
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

  void reset() {
    _uuid = '';
    _imageurl = null;
    _description = '';
    _donationDate = '';
    _donationTime = '';
    _quantity = '';
    _location = '';
    _latitude = 0.0;
    _longitude = 0.0;
    notifyListeners();
  }
}
