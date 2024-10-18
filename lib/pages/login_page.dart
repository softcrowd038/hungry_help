import 'package:flutter/material.dart';
import 'package:quick_social/pages/profile_data_page.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:quick_social/widgets/layout/text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey _globalKey = GlobalKey();

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
                      fontWeight: FontWeight.w700),
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
                Padding(
                  padding: EdgeInsets.all(
                      MediaQuery.of(context).size.height * 0.012),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forget Password?',
                        style: TextStyle(
                            fontSize:
                                MediaQuery.of(context).size.height * 0.022),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileDataPage()));
                  },
                  child: const ButtonWidget(
                    borderRadius: 0.06,
                    height: 0.06,
                    width: 1,
                    text: 'SIGN IN',
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
