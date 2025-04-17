import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quick_social/data/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonorInfo {
  Future<Map<String, dynamic>> getDonorDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString('user_uuid');
    final url = Uri.parse('$baseUrl/donor/meals/$uuid');
    final authToken = prefs.getString('auth_token');

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic>) {
          if (responseData['success'] == true && responseData['data'] != null) {
            return responseData['data'] as Map<String, dynamic>;
          } else {
            throw Exception('No data available');
          }
        } else {
          throw Exception('Unexpected JSON structure');
        }
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
