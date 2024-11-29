import 'dart:convert';
import 'package:quick_social/data/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ClosestInformerService {
  List<dynamic> data = [];
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
}
