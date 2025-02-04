import 'package:flutter/material.dart';
import 'package:quick_social/pages/register_page.dart';
import 'package:quick_social/widgets/app_logo.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  void splashing(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), () async {
        if (context.mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const RegisterPage()));
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    splashing(context); // Trigger the delayed navigation

    return const Scaffold(
      body: Center(
        child: AppLogo(), // Use the AppLogo widget with GIF animation
      ),
    );
  }
}
