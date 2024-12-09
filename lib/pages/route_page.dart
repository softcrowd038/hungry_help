import 'package:flutter/material.dart';
import 'package:quick_social/widgets/capture_post_image.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<StatefulWidget> createState() => _RoutePage();
}

class _RoutePage extends State<RoutePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              'https://s3.amazonaws.com/images.seroundtable.com/google-maps-avg-reviews-restaurants-nyc-1623448326.png',
              scale: 1.0,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.75,
              width: MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 20),
            const ButtonWidget(
              borderRadius: 0.06,
              height: 0.06,
              width: 1,
              text: 'DELIVER',
              textFontSize: 0.022,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CaptureImageOrVideoPage()));
              },
              child: const ButtonWidget(
                borderRadius: 0.06,
                height: 0.06,
                width: 1,
                text: 'ADD POST',
                textFontSize: 0.022,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
