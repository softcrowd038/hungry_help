import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart' as loc;
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';

class InformerCameraReviewPage extends StatefulWidget {
  final XFile? mediaFile;
  final String count;

  const InformerCameraReviewPage({
    super.key,
    required this.count,
    required this.mediaFile,
  });

  @override
  State<InformerCameraReviewPage> createState() => _InformerCameraReviewPage();
}

class _InformerCameraReviewPage extends State<InformerCameraReviewPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _locationNameController = TextEditingController();

  loc.LocationData? _currentLocation;
  String? _locationName;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;

  final loc.Location _locationService = loc.Location();

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await _locationService.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _locationService.requestService();
        if (!serviceEnabled) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      loc.PermissionStatus permissionGranted =
          await _locationService.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _locationService.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      _currentLocation = await _locationService.getLocation();
      _latitude = _currentLocation?.latitude;
      _longitude = _currentLocation?.longitude;

      if (_latitude != null && _longitude != null) {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(_latitude!, _longitude!);
        Placemark place = placemarks[0];

        setState(() {
          _locationName =
              '${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
          _locationNameController.text = _locationName!;
        });
      }
    } catch (e) {
      setState(() {
        _locationNameController.text = 'Failed to get location';
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      print('Media File: ${widget.mediaFile?.path}');
      print('Description: ${widget.count}');
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
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    super.dispose();
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
                          'https://img.freepik.com/free-vector/current-location-concept-illustration_114360-4406.jpg',
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
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      'Add Location',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Add needy people\'s current location',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.0080,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (widget.mediaFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.height * 0.01,
                              ),
                              child: Image.file(
                                File(widget.mediaFile!.path),
                                width:
                                    MediaQuery.of(context).size.height * 0.06,
                                height:
                                    MediaQuery.of(context).size.height * 0.06,
                                fit: BoxFit.cover,
                              ),
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.06,
                              decoration: BoxDecoration(
                                // border: Border.all(),
                                borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height * 0.010,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(
                                      MediaQuery.of(context).size.height *
                                          0.0080,
                                    ),
                                    child: const Text(
                                      'People Count:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 3,
                                    ),
                                  ),
                                  Text(
                                    widget.count,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.012,
                      ),
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
                      onTap: _submitForm,
                      child: const ButtonWidget(
                        borderRadius: 0.06,
                        height: 0.06,
                        width: 1,
                        text: 'SUBMIT',
                        textFontSize: 0.022,
                      ),
                    ),
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
