// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/provider/donor_data_provider.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddLocationData extends StatefulWidget {
  const AddLocationData({super.key});

  @override
  State<AddLocationData> createState() => _AddLocationData();
}

class _AddLocationData extends State<AddLocationData> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController _locationNameController = TextEditingController();
  String? _locationName;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  bool _isLoading = false;

  final loc.Location location = loc.Location();

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final serviceEnabled =
          await location.serviceEnabled() || await location.requestService();

      if (!serviceEnabled) {
        throw 'Location services disabled';
      }

      final permissionGranted = await location.hasPermission() ==
              loc.PermissionStatus.granted ||
          await location.requestPermission() == loc.PermissionStatus.granted;

      if (!permissionGranted) {
        throw 'Location permission denied';
      }

      final currentLocation = await location.getLocation();
      final latitude = currentLocation.latitude;
      final longitude = currentLocation.longitude;

      if (latitude != null && longitude != null) {
        final placemarks = await placemarkFromCoordinates(latitude, longitude);

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          _locationName =
              '${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        } else {
          _locationName = 'No address found';
        }

        setState(() {
          _latitude = latitude;
          _longitude = longitude;
          _locationNameController.text = _locationName ?? '';
        });
      } else {
        throw 'Unable to retrieve coordinates';
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _locationNameController.text = 'Error retrieving location';
      });
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> submitDonation() async {
    if (_isLoading) return;

    if (!_globalKey.currentState!.validate()) return;

    if (_locationNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location is required')),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location coordinates are missing')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final donorDataProvider =
          Provider.of<DonorDataProvider>(context, listen: false);
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

      final url = Uri.parse('$baseUrl/donormeal');
      final request = http.MultipartRequest('POST', url)
        ..fields['uuid'] = uuid!
        ..fields['description'] = donorDataProvider.description
        ..fields['current_date'] = donorDataProvider.donationDate
        ..fields['current_time'] = donorDataProvider.donationTime
        ..fields['quantity'] = donorDataProvider.quantity
        ..fields['location'] = _locationNameController.text
        ..fields['latitude'] = _latitude.toString()
        ..fields['longitude'] = _longitude.toString()
        ..headers['Authorization'] = 'Bearer $token';

      if (donorDataProvider.imageurl != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imageurl',
          donorDataProvider.imageurl!.path,
        ));
      }

      final response = await request.send();

      if (response.statusCode == 201) {
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseData.body);
        print('Donation data submitted successfully: $jsonResponse');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Donation data submitted successfully!')),
        );
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseData.body);
        final message =
            jsonResponse['message'] ?? 'Failed to submit donation data';
        print('Failed: ${response.statusCode} - $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Location is required';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        submitDonation();
                      },
                      child: _isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.orange),
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
