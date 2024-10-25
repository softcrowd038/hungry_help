// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/pages/profile_image.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:quick_social/widgets/layout/text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final String _loginUrl = 'http://192.168.1.2:8080/api/v1/login';

  Future<void> _loginUser() async {
    if (!_globalKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final Map<String, dynamic> loginData = {
      'email': _emailController.text,
      'password': _passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(_loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(loginData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String token = responseData['token'];
        final String username = responseData['username'];
        final String email = responseData['email'];
        final String uuid = responseData['uuid'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_name', username);
        await prefs.setString('user_email', email);
        await prefs.setString('user_uuid', uuid);
        final profileStatus = prefs.getString('status');

        if (profileStatus == 'active') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileImagePage()),
          );
        }
      } else {
        final message = jsonDecode(response.body)['message'] ?? 'Login failed';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _globalKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image(
                  image: const AssetImage('assets/images/login.png'),
                  height: MediaQuery.of(context).size.height * 0.400,
                  width: MediaQuery.of(context).size.height * 0.400,
                ),
                const Text('You are just one step away'),
                Text(
                  'SIGN IN',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.035,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextFieldWidget(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    }
                    return null;
                  },
                ),
                TextFieldWidget(
                  controller: _passwordController,
                  hintText: 'Password',
                  keyboardType: TextInputType.text,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(
                    MediaQuery.of(context).size.height * 0.012,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.022,
                        ),
                      )
                    ],
                  ),
                ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : GestureDetector(
                        onTap: _loginUser,
                        child: const ButtonWidget(
                          borderRadius: 0.06,
                          height: 0.06,
                          width: 1,
                          text: 'SIGN IN',
                          textFontSize: 0.022,
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
