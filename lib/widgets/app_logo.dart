import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class AppLogo extends StatefulWidget {
  const AppLogo({super.key});

  @override
  State<StatefulWidget> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late GifController _gifController;

  @override
  void initState() {
    super.initState();

    _gifController = GifController(vsync: this);

    _gifController.repeat(min: 0, max: 1, period: const Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return Gif(
        controller: _gifController,
        image: const AssetImage(
          'assets/images/logo.gif',
        ),
        height: MediaQuery.of(context).size.height * 0.450,
        width: MediaQuery.of(context).size.width * 0.450);
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }
}
