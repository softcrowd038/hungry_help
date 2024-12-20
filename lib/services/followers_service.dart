// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:quick_social/data/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FollowersService {
  Future<Map<String, dynamic>> getFollowersCount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');

    final url = Uri.parse('$baseUrl/follow-stats/$uuid');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['stats'] != null) {
          final stats = responseData['stats'];
          return {
            'total_followers':
                int.tryParse(stats['total_followers'].toString()) ?? 0,
          };
        } else {
          return {'total_followers': 0};
        }
      } else {
        print('Failed to fetch followers: ${response.statusCode}');
        return {'total_followers': 0};
      }
    } catch (e) {
      print('Error fetching followers count: $e');
      return {'total_followers': 0};
    }
  }

  Future<Map<String, dynamic>> getFollowingCount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');

    final url = Uri.parse('$baseUrl/following-stats/$uuid');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true && responseData['stats'] != null) {
          final stats = responseData['stats'];
          return {
            'total_following':
                int.tryParse(stats['total_following'].toString()) ?? 0,
          };
        } else {
          return {'total_following': 0};
        }
      } else {
        print('Failed to fetch following: ${response.statusCode}');
        return {'total_following': 0};
      }
    } catch (e) {
      print('Error fetching following count: $e');
      return {'total_following': 0};
    }
  }
}
