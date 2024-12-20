// ignore_for_file: use_build_context_synchronously, body_might_complete_normally_nullable, avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/models/user_model.dart';
import 'package:quick_social/pages/pages.dart';
import 'package:quick_social/provider/user_provider.dart';
import 'package:quick_social/services/followers_service.dart';
import 'package:quick_social/services/user_services.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:quick_social/widgets/layout/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileUpdatePage extends StatefulWidget {
  const ProfileUpdatePage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  DateTime? _selectedDate;
  File? _image;
  Map<String, dynamic> profileData = {};
  FollowersService followersService = FollowersService();
  UserAccount? profile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final uuid = sharedPreferences.getString('user_uuid');

    if (uuid == null) {
      print('User UUID is missing');
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      userProvider.fetchUserProfile(uuid);
      final fetchedProfile = userProvider.getUser(uuid);

      if (mounted) {
        setState(() {
          profile = fetchedProfile;
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

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

  Future<void> _submitProfile() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final uri = Uri.parse('$baseUrl/updateprofile/$uuid');
        var request = http.MultipartRequest('PUT', uri)
          ..headers['Authorization'] = 'Bearer $authToken';

        if (_usernameController.text.isNotEmpty) {
          request.fields['username'] = _usernameController.text;
        }
        if (_firstnameController.text.isNotEmpty) {
          request.fields['firstname'] = _firstnameController.text;
        }
        if (_lastnameController.text.isNotEmpty) {
          request.fields['lastname'] = _lastnameController.text;
        }
        if (_locationController.text.isNotEmpty) {
          request.fields['location'] = _locationController.text;
        }
        if (_birthdateController.text.isNotEmpty) {
          request.fields['birthdate'] = _birthdateController.text;
        }

        if (_image != null) {
          var imageFile = await http.MultipartFile.fromPath(
            'imageurl',
            _image!.path,
            contentType: MediaType('image', 'jpeg'),
          );
          request.files.add(imageFile);
        }

        var response = await request.send();
        var responseBody = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          setState(() {
            _image = null;
            _formKey.currentState?.reset();
            isLoading = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to update profile: ${_parseError(responseBody) ?? response.statusCode}',
              ),
            ),
          );
        }
      } on SocketException {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String? _parseError(String responseBody) {
    try {
      final error = jsonDecode(responseBody);
      if (error['message'] != null) return error['message'];
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    ThemeData theme = Theme.of(context);

    if (userProvider.errorMessage != null) {
      return Center(child: Text('Error: ${userProvider.errorMessage}'));
    }

    if (profile == null) {
      return const Center(child: Text(''));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.016),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.height * 0.070,
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : NetworkImage(
                              '$imageBaseUrl${profile!.userProfile.imageurl}')
                          as ImageProvider,
                  child: _image == null
                      ? Icon(
                          Icons.camera_alt,
                          size: MediaQuery.of(context).size.height * 0.030,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.016),
              TextFieldWidget(
                controller: _usernameController,
                hintText: profile!.userProfile.username ?? 'username ',
                keyboardType: TextInputType.text,
                prefixIcon: const Icon(Icons.person_pin),
                validator: (p0) {},
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.016),
              TextFieldWidget(
                controller: _firstnameController,
                hintText: profile!.userProfile.firstname ?? 'First Name',
                keyboardType: TextInputType.text,
                prefixIcon: const Icon(Icons.person_rounded),
                validator: (p0) {},
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.016),
              TextFieldWidget(
                controller: _lastnameController,
                hintText: profile!.userProfile.lastname ?? 'Last Name',
                keyboardType: TextInputType.text,
                prefixIcon: const Icon(Icons.person_3),
                validator: (p0) {},
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.016),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.height * 0.015),
                child: TextFormField(
                  controller: _birthdateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: formatDate(profile!.userProfile.birthdate!),
                    prefixIcon: const Icon(Icons.cake),
                  ),
                  onTap: () => _selectBirthdate(context),
                  validator: (value) {},
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.024),
              GestureDetector(
                onTap: _submitProfile,
                child: isLoading == true
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.024),
              GestureDetector(
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.10,
                    decoration: BoxDecoration(
                        color: theme.colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height * 0.015)),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            'Delete Your Account Permanantly',
                            style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.018),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.red,
                          )
                        ])),
              )
            ],
          ),
        ),
      ),
    );
  }
}

void _showDeleteAccountDialog(BuildContext parentContext) {
  showDialog(
    context: parentContext,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
          'Do you really want to delete your account permanently? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final accountService = UserApiService();
              Navigator.of(context).pop();

              try {
                final response = await accountService.deleteUser(parentContext);
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(content: Text('Account deleted: $response')),
                );
              } catch (e) {
                print('Error deleting account: $e');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
