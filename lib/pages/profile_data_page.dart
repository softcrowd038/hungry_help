import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/pages/profile_location_page.dart';
import 'package:quick_social/provider/profile_data_provider.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:quick_social/widgets/layout/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDataPage extends StatefulWidget {
  const ProfileDataPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileDataPage();
}

class _ProfileDataPage extends State<ProfileDataPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  String? username;
  String? email;

  @override
  void initState() {
    super.initState();
    _getAuthToken();
  }

  Future<void> _getAuthToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        username = prefs.getString('user_name') ?? 'Unknown User';
        email = prefs.getString('user_email') ?? 'Unknown Email';
      });
    } catch (e) {
      _showSnackBar('Failed to fetch user data.');
    }
  }

  String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onNextButtonPressed() {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please correct the errors in the form.');
      return;
    }

    final profileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    profileProvider.setFirstname(_firstNameController.text.trim());
    profileProvider.setLastname(_lastNameController.text.trim());

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileLocationPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<UserProfileProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.016),
                    Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.0120),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.150,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height * 0.0150,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5,
                              color: Colors.black.withOpacity(0.2),
                              offset: const Offset(1, 1),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                              MediaQuery.of(context).size.height * 0.0120),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.130,
                                width:
                                    MediaQuery.of(context).size.height * 0.130,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.orange,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    MediaQuery.of(context).size.height * 0.130,
                                  ),
                                ),
                                child: profileProvider.imageUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          MediaQuery.of(context).size.height *
                                              0.130,
                                        ),
                                        child: Image.file(
                                          profileProvider.imageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.person,
                                        size:
                                            MediaQuery.of(context).size.height *
                                                0.130,
                                        color: Colors.orange,
                                      ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(
                                    MediaQuery.of(context).size.height * 0.012),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      capitalizeFirstLetter(
                                          username ?? 'Fetching username...'),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.024,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      email ?? 'Fetching email...',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.020,
                                        fontWeight: FontWeight.w200,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.012),
                      child: Text(
                        'Enter Your First and Last name',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.height * 0.018,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFieldWidget(
                            controller: _firstNameController,
                            hintText: 'First Name',
                            keyboardType: TextInputType.text,
                            prefixIcon: const Icon(Icons.person),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'First name cannot be empty.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFieldWidget(
                            controller: _lastNameController,
                            hintText: 'Last Name',
                            keyboardType: TextInputType.text,
                            prefixIcon: const Icon(Icons.person),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Last name cannot be empty.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.016),
                    GestureDetector(
                      onTap: _onNextButtonPressed,
                      child: const ButtonWidget(
                        borderRadius: 0.06,
                        height: 0.06,
                        width: 1,
                        text: 'NEXT',
                        textFontSize: 0.022,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
