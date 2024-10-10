import 'package:flutter/material.dart';
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
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _globalKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  image: const AssetImage('assets/images/registration.jpg'),
                  height: MediaQuery.of(context).size.height * 0.400,
                  width: MediaQuery.of(context).size.height * 0.400,
                ),
                const Text('We are waiting for you'),
                Text(
                  'SIGN UP',
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.035,
                      fontWeight: FontWeight.w700),
                ),
                TextFieldWidget(
                  controller: _usernameController,
                  hintText: 'Username',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.person),
                  validator: (p0) {},
                ),
                TextFieldWidget(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.person),
                  validator: (p0) {},
                ),
                TextFieldWidget(
                  controller: _passwordController,
                  hintText: 'Password',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.person),
                  validator: (p0) {},
                ),
                TextFieldWidget(
                  controller: _reentrController,
                  hintText: 'Re-Enter Password',
                  keyboardType: TextInputType.text,
                  prefixIcon: const Icon(Icons.person),
                  validator: (p0) {},
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: const ButtonWidget(
                    borderRadius: 0.06,
                    height: 0.06,
                    width: 1,
                    text: 'SIGN UP',
                    textFontSize: 0.022,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
