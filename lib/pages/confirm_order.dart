// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/pages/route_page.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ConfirmOrder extends StatefulWidget {
  const ConfirmOrder({super.key});

  @override
  State<StatefulWidget> createState() => _ConfirmOrder();
}

class _ConfirmOrder extends State<ConfirmOrder> {
  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> _getClosestInformerDetails(
      String donorUUID, String informerUUID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final url =
        Uri.parse('$baseUrl/closest-informers/$donorUUID/$informerUUID');
    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404 || response.statusCode == 500) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        throw Exception('Error fetching Data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

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
