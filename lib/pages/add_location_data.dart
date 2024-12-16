// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/provider/donor_data_provider.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddLocationData extends StatefulWidget {
  const AddLocationData({
    super.key,
  });

  @override
  State<AddLocationData> createState() => _AddLocationData();
}

class _AddLocationData extends State<AddLocationData> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController _locationNameController = TextEditingController();
  loc.LocationData? _currentLocation;
  String? _locationName;
  double? _latitude;
  double? _longitude;
  bool _isLoadingLocation = false;
  bool _isLoading = false;

  final loc.Location location = loc.Location();

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) throw 'Location services disabled';
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          throw 'Location permission denied';
        }
      }

      _currentLocation = await location.getLocation();
      _latitude = _currentLocation?.latitude;
      _longitude = _currentLocation?.longitude;

      if (_latitude != null && _longitude != null) {
        List<Placemark> placemarks =
            await placemarkFromCoordinates(_latitude!, _longitude!);

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          setState(() {
            _locationName =
                '${place.name}, ${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
            _locationNameController.text = _locationName!;
          });
        } else {
          setState(() {
            _locationNameController.text = 'No address found';
          });
        }
      } else {
        setState(() {
          _locationNameController.text = 'Coordinates unavailable';
        });
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
    setState(() {
      _isLoading = true;
    });

    if (_globalKey.currentState!.validate()) {
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

      final String authToken = token;
      final url = Uri.parse('http://192.168.1.3:8080/api/v1/donormeal');

      var request = http.MultipartRequest('POST', url);
      request.fields['uuid'] = uuid!;
      request.fields['description'] = donorDataProvider.description;
      request.fields['current_date'] = donorDataProvider.donationDate;
      request.fields['current_time'] = donorDataProvider.donationTime;
      request.fields['quantity'] = donorDataProvider.quantity;
      request.fields['location'] = _locationNameController.text;
      request.fields['latitude'] = _latitude.toString();
      request.fields['longitude'] = _longitude.toString();

      if (donorDataProvider.imageurl != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'imageurl',
          donorDataProvider.imageurl!.path,
        ));
      }

      request.headers['Authorization'] = 'Bearer $authToken';

      try {
        var response = await request.send();
        if (response.statusCode == 201) {
          final responseData = await http.Response.fromStream(response);
          final jsonResponse = json.decode(responseData.body);

          print('Donation data submitted successfully: $jsonResponse');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Donation data submitted successfully!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          final responseData = await http.Response.fromStream(response);
          final jsonResponse = json.decode(responseData.body);
          final message =
              jsonResponse['message'] ?? 'Failed to submit donation data';
          print(
              'Failed to submit donation data: ${response.statusCode} - $message');
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
  Widget build(BuildContext context) {
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
                        submitDonation();
                      },
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
