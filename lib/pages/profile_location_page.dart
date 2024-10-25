// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/pages/profile_birthdate_page.dart';
import 'package:quick_social/provider/profile_data_provider.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';

class ProfileLocationPage extends StatefulWidget {
  const ProfileLocationPage({
    super.key,
  });

  @override
  State<ProfileLocationPage> createState() => _ProfileLocationPage();
}

class _ProfileLocationPage extends State<ProfileLocationPage> {
  final GlobalKey _globalKey = GlobalKey();

  final TextEditingController _locationNameController = TextEditingController();

  loc.LocationData? _currentLocation;
  String? _locationName;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  final loc.Location location = loc.Location();

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    _currentLocation = await location.getLocation();
    _latitude = _currentLocation?.latitude;
    _longitude = _currentLocation?.longitude;

    if (_latitude != null && _longitude != null) {
      try {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(_latitude!, _longitude!);
        Placemark place = placemarks[0];

        setState(() {
          _locationName =
              '${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
          _locationNameController.text = _locationName!;
          _isLoadingLocation = false;
        });
      } catch (e) {
        setState(() {
          _locationNameController.text = 'Failed to get location';
          _isLoadingLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 500.0,
              floating: false,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned(
                      top: 60,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 350,
                        child: Image.network(
                          'https://img.freepik.com/free-vector/location-review-concept-illustration_114360-4711.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 22,
                          ),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Form(
                key: _globalKey,
                child: Column(
                  children: [
                    const Text(
                      'Add Location',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Add your current location',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.012),
                      child: TextFormField(
                        controller: _locationNameController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Tap to get location',
                          prefixIcon: _isLoadingLocation
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(),
                                )
                              : const Icon(Icons.place),
                        ),
                        onTap: _getCurrentLocation,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        profileProvider
                            .setLocation(_locationNameController.text);
                        profileProvider.setLatitude(_latitude!);
                        profileProvider.setLongitude(_longitude!);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                const ProfileBirthdatePage()));
                      },
                      child: const ButtonWidget(
                        borderRadius: 0.06,
                        height: 0.06,
                        width: 1,
                        text: 'Add Location',
                        textFontSize: 0.022,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
