// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/provider/informer_data_provider.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InformerCameraReviewPage extends StatefulWidget {
  const InformerCameraReviewPage({
    super.key,
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
  bool _isLoading = false;
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

  Future<void> submitDonation() async {
    setState(() {
      _isLoading = true;
    });

    if (_formKey.currentState!.validate()) {
      final informerProfileProvider =
          Provider.of<InformerDataProvider>(context, listen: false);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final uuid = prefs.getString('user_uuid');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User authentication token is missing.')),
        );
        return;
      }

      final String authToken = token;
      final url = Uri.parse('http://192.168.1.2:8080/api/v1/informer');

      var request = http.MultipartRequest('POST', url);
      request.fields['uuid'] = uuid!;
      request.fields['description'] = informerProfileProvider.description;
      request.fields['capture_date'] = informerProfileProvider.donationDate;
      request.fields['capture_time'] = informerProfileProvider.donationTime;
      request.fields['count'] = informerProfileProvider.quantity;
      request.fields['location'] = _locationNameController.text;
      request.fields['latitude'] = _latitude.toString();
      request.fields['longitude'] = _longitude.toString();

      if (informerProfileProvider.imageurl != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imageurl',
          informerProfileProvider.imageurl!.path,
        ));
      }

      request.headers['Authorization'] = 'Bearer $authToken';

      try {
        var response = await request.send();
        if (response.statusCode == 201) {
          final responseData = await http.Response.fromStream(response);
          final jsonResponse = json.decode(responseData.body);

          print('Informer data submitted successfully: $jsonResponse');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Informer data submitted successfully!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          final responseData = await http.Response.fromStream(response);
          final jsonResponse = json.decode(responseData.body);
          final message =
              jsonResponse['message'] ?? 'Failed to submit Informer data';
          print(
              'Failed to submit Informer data: ${response.statusCode} - $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } catch (e) {
        print('Error submitting donation data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final informerDataProvider = Provider.of<InformerDataProvider>(context);
    ThemeData theme = Theme.of(context);
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
                          if (informerDataProvider.imageurl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                MediaQuery.of(context).size.height * 0.01,
                              ),
                              child: Image.file(
                                informerDataProvider.imageurl!,
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
                                    informerDataProvider.quantity,
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
                      onTap: submitDonation,
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.colorScheme.primary),
                            )
                          : const ButtonWidget(
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
