// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/models/story/register_model.dart';
import 'dart:convert';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:quick_social/widgets/layout/text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _reentrController = TextEditingController();
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  bool _isLoading = false;
  final String _registerUrl = 'http://192.168.1.4:8080/api/v1/register';
  Future<void> _registerUser() async {
    if (!_globalKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    UserModel user = UserModel(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    try {
      final response = await http.post(
        Uri.parse(_registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      if (response.statusCode == 201) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      } else {
        final message =
            jsonDecode(response.body)['message'] ?? 'Registration failed';

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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage('assets/images/registration.png'),
                  height: MediaQuery.of(context).size.height * 0.400,
                  width: MediaQuery.of(context).size.height * 0.400,
                ),
                const Text('We are waiting for you'),
                Text(
                  'SIGN UP',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.035,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextFieldWidget(
                  controller: _usernameController,
                  hintText: 'Username',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {},
                ),
                TextFieldWidget(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  validator: (value) {},
                ),
                TextFieldWidget(
                  controller: _passwordController,
                  hintText: 'Password',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: true,
                  validator: (value) {},
                ),
                TextFieldWidget(
                  controller: _reentrController,
                  hintText: 'Re-Enter Password',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.lock),
                  obscureText: true,
                  validator: (value) {},
                ),
                _isLoading
                    ? const CircularProgressIndicator()
                    : GestureDetector(
                        onTap: _registerUser,
                        child: const ButtonWidget(
                          borderRadius: 0.06,
                          height: 0.06,
                          width: 1,
                          text: 'SIGN UP',
                          textFontSize: 0.022,
                        ),
                      ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.w700),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
