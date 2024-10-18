// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/pages/main_page.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';

class AddLocationData extends StatefulWidget {
  final XFile? mediaFile;
  final String description;
  final String expiryDate;
  final String expiryTime;
  final String quantiy;

  const AddLocationData(
      {super.key,
      required this.description,
      required this.expiryDate,
      required this.expiryTime,
      required this.mediaFile,
      required this.quantiy});

  @override
  State<AddLocationData> createState() => _AddLocationData();
}

class _AddLocationData extends State<AddLocationData> {
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

  void _submitForm() {
    print('Media File: ${widget.mediaFile?.path}');
    print('Description: ${widget.description}');
    print('Expiry Date: ${widget.expiryDate}');
    print('Expiry Time: ${widget.expiryTime}');
    print('Quantity: ${widget.quantiy}');
    print('Location Name: ${_locationNameController.text}');
    print('Latitude: $_latitude');
    print('Longitude: $_longitude');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data submitted successfully!'),
      ),
    );
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
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
                          'https://img.freepik.com/free-vector/address-illustration-concept_114360-301.jpg?size=626&ext=jpg',
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
                        _submitForm();
                      },
                      child: const ButtonWidget(
                        borderRadius: 0.06,
                        height: 0.06,
                        width: 1,
                        text: 'SUBMIT',
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
