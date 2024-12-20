// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ClosestInformerService {
  Future<dynamic> postClosestLocationData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('user_uuid');
    String? authToken = prefs.getString('auth_token');

    final url = Uri.parse('$baseUrl/storeClosestInformers/$uuid');
    try {
      final response = await http.post(url, headers: {
        'Authorization': 'Bearer $authToken',
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post data: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getClosestLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('user_uuid');
    final url = Uri.parse('$baseUrl/closest-informers/$uuid');
    final authToken = prefs.getString('auth_token');

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData['data'] != null) {
          return responseData['data'];
        } else if (responseData is List) {
          return responseData;
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else {
        throw Exception('No data found');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getAllInformers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final url = Uri.parse('$baseUrl/getinformer');
    final authToken = prefs.getString('auth_token');

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData['data'] != null) {
          return responseData['data'];
        } else if (responseData is List) {
          return responseData;
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else {
        throw Exception('No data found');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>?> getClosestInformerDetails(
      BuildContext context, String closestID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/closest-info/$closestID');

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic> &&
            responseData['data'] != null) {
          print(responseData['data']);
          return responseData['data'];
        } else if (responseData is List) {
          return responseData;
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else if (response.statusCode == 500) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        throw Exception('Resource not found or server error');
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> updateStatusClosestInformer(
      String closestID, Map<String, dynamic> fieldsToUpdate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/informerClosestUpdate/$closestID');

    try {
      // Prepare the data dynamically based on the fields passed
      final body = jsonEncode(fieldsToUpdate); // Fields passed as map

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json', // Set content type as JSON
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error Updating ${response.body}');
      }
    } catch (e) {
      throw Exception('Error ,$e');
    }
  }

  Future<void> updateStatusInformer(
      String uuid, Map<String, dynamic> fieldsToUpdate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/informerupdate/$uuid');

    try {
      // Prepare the data dynamically based on the fields passed
      final body = jsonEncode(fieldsToUpdate); // Fields passed as map

      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json', // Set content type as JSON
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error Updating ${response.body}');
      }
    } catch (e) {
      throw Exception('Error ,$e');
    }
  }
}
