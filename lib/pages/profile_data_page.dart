import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:quick_social/widgets/layout/text_field.dart';

class ProfileDataPage extends StatefulWidget {
  const ProfileDataPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileDataPage();
}

class _ProfileDataPage extends State<ProfileDataPage> {
  final GlobalKey _globalKey = GlobalKey();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _familyMembersController =
      TextEditingController();
  final TextEditingController _birthdateController = TextEditingController();
  final TextEditingController _occupationController = TextEditingController();

  XFile? _profilePic;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    _profilePic = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: SafeArea(
            child: Form(
              key: _globalKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.008),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.height * 0.070,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _profilePic != null
                            ? FileImage(File(_profilePic!.path))
                            : null,
                        child: _profilePic == null
                            ? Icon(Icons.camera_alt,
                                size:
                                    MediaQuery.of(context).size.height * 0.040)
                            : null,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(theme.colorScheme.primary),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'ADD Image',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  TextFieldWidget(
                    controller: _userNameController,
                    hintText: 'Username',
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(Icons.account_circle),
                    validator: (p0) {},
                  ),
                  TextFieldWidget(
                    controller: _firstNameController,
                    hintText: 'First Name',
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(Icons.person),
                    validator: (p0) {},
                  ),
                  TextFieldWidget(
                    controller: _lastNameController,
                    hintText: 'Last Name',
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(Icons.person),
                    validator: (p0) {},
                  ),
                  TextFieldWidget(
                    controller: _locationController,
                    hintText: 'Location',
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(Icons.location_on),
                    validator: (p0) {},
                  ),
                  TextFieldWidget(
                    controller: _familyMembersController,
                    hintText: 'Number of Family Members',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.family_restroom),
                    validator: (p0) {},
                  ),
                  TextFieldWidget(
                    controller: _birthdateController,
                    hintText: 'Birthdate',
                    keyboardType: TextInputType.datetime,
                    prefixIcon: const Icon(Icons.calendar_today),
                    validator: (p0) {},
                  ),
                  TextFieldWidget(
                    controller: _occupationController,
                    hintText: 'Occupation',
                    keyboardType: TextInputType.text,
                    prefixIcon: const Icon(Icons.work),
                    validator: (p0) {},
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.016),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomePage()));
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
        ),
      ),
    );
  }
}
