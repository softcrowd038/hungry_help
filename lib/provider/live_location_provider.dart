// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationProvider extends ChangeNotifier {
  LatLng? _currentPosition;
  String? _currentAddress; 

  LatLng? get currentPosition => _currentPosition;
  String? get currentAddress => _currentAddress;

  void updateCurrentPosition(LatLng position) {
    _currentPosition = position;
    notifyListeners();
  }

  Future<void> requestLocationPermissionAndGetCurrentLocation() async {
    try {
      var status = await Permission.locationWhenInUse.status;
      if (status.isDenied || status.isPermanentlyDenied) {
        var result = await Permission.locationWhenInUse.request();
        if (result.isGranted) {
          await _getCurrentLocation();
        }
      } else if (status.isGranted) {
        await _getCurrentLocation();
      }
    } catch (e) {
      print('Error requesting location permission: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      updateCurrentPosition(LatLng(position.latitude, position.longitude));
      await _getAddressFromLatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        _currentAddress =
            '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}';
      } else {
        _currentAddress = 'Address not found';
      }
    } catch (e) {
      print('Error fetching address: $e');
      _currentAddress = 'Error fetching address';
    }
    notifyListeners();
  }
}
