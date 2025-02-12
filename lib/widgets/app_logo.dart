import 'package:flutter/material.dart';

class AppLogo extends StatefulWidget {
  const AppLogo({super.key});

  @override
  State<StatefulWidget> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.141592653589793,
            child: child,
          );
        },
        child: Image.asset(
          'assets/images/logo6.png',
          height: screenHeight * 0.2,
          width: screenHeight * 0.2,
        ),
      ),
    );
  }
}
