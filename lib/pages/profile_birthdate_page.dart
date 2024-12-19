// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/provider/profile_data_provider.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfileBirthdatePage extends StatefulWidget {
  const ProfileBirthdatePage({super.key});

  @override
  State<ProfileBirthdatePage> createState() => _ProfileBirthdatePage();
}

class _ProfileBirthdatePage extends State<ProfileBirthdatePage> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  final TextEditingController _birthdateController = TextEditingController();
  DateTime? _selectedDate;

  void _selectBirthdate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdateController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  Future<void> submitProfile() async {
    if (_globalKey.currentState!.validate()) {
      final profileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      profileProvider.setBirthdate(_birthdateController.text);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final username = prefs.getString('user_name');
      final uuid = prefs.getString('user_uuid');

      if (token == null || username == null || uuid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User details are missing.')),
        );
        return;
      }

      final String authToken = token;
      final url = Uri.parse('http://192.168.1.2:8080/api/v1/profiledetails');

      var request = http.MultipartRequest('POST', url);
      request.fields['uuid'] = uuid;
      request.fields['username'] = username;
      request.fields['firstname'] = profileProvider.firstname;
      request.fields['lastname'] = profileProvider.lastname;
      request.fields['location'] = profileProvider.location;
      request.fields['latitude'] = profileProvider.latitude.toString();
      request.fields['longitude'] = profileProvider.longitude.toString();
      request.fields['birthdate'] = profileProvider.birthdate;

      if (profileProvider.imageUrl != null) {
        request.files.add(await http.MultipartFile.fromPath(
            'imageurl', profileProvider.imageUrl!.path));
      }

      request.headers['Authorization'] = 'Bearer $authToken';

      try {
        var response = await request.send();
        if (response.statusCode == 201) {
          final responseData = await http.Response.fromStream(response);
          final jsonResponse = json.decode(responseData.body);

          print('Profile submitted successfully: $jsonResponse');
          await prefs.setString('status', 'active');
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()));
        } else {
          final responseData = await http.Response.fromStream(response);
          final jsonResponse = json.decode(responseData.body);
          final message = jsonResponse['message'] ?? 'Failed to submit profile';
          print('Failed to submit profile: ${response.statusCode} - $message');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } catch (e) {
        print('Error submitting profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
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
                        height: 450,
                        child: Image.network(
                          'https://img.freepik.com/free-vector/illustrated-people-celebrating-birthday-party_23-2149118216.jpg',
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
                      'Add Birthdate',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      'Select your birthdate',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.012),
                      child: TextFormField(
                        controller: _birthdateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          hintText: 'Tap to select birthdate',
                          prefixIcon: Icon(Icons.cake),
                        ),
                        onTap: () => _selectBirthdate(context),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a birthdate';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        submitProfile();
                      },
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
