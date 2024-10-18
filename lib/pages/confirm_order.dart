import 'package:flutter/material.dart';
import 'package:quick_social/pages/route_page.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';

class ConfirmOrder extends StatefulWidget {
  const ConfirmOrder({super.key});

  @override
  State<StatefulWidget> createState() => _ConfirmOrder();
}

class _ConfirmOrder extends State<ConfirmOrder> {
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
              'https://img.freepik.com/free-vector/thank-you-placard-concept-illustration_114360-13436.jpg', // Valid image URL
              scale: 1.0,
              fit: BoxFit.cover,
              height: 300,
              width: MediaQuery.of(context).size.width,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const RoutePage()));
              },
              child: const ButtonWidget(
                borderRadius: 0.06,
                height: 0.06,
                width: 1,
                text: 'CONFIRM HELP',
                textFontSize: 0.022,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
