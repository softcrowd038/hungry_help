// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FollowStatusProvider with ChangeNotifier {
  final Map<String, bool> _followStatusMap = {};
  final Map<String, int> _followerCountMap = {};

  Map<String, bool> get followStatusMap => _followStatusMap;

  bool isFollowing(String userUuid) => _followStatusMap[userUuid] ?? false;
  int followerCount(String userUuid) => _followerCountMap[userUuid] ?? 0;

  Future<void> getFollowerInitialCount(
      BuildContext context, String userUuid) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final currentUserUuid = sharedPreferences.getString('user_uuid');

    if (authToken == null || currentUserUuid == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    final url = Uri.parse('$baseUrl/follower/$userUuid/$currentUserUuid');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final statusData = data['data'].first;
          bool isFollowing = (statusData['status'] ?? 'unfollow') == 'follow';
          int followerCount = statusData['follower_count'] ?? 0;

          _followStatusMap[userUuid] = isFollowing;
          _followerCountMap[userUuid] = followerCount;
          notifyListeners();
        }
      } else {
        print('Error fetching follow status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching follow status: $e');
    }
  }

  Future<void> toggleFollowStatus(BuildContext context, String userUuid) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final currentUserUuid = sharedPreferences.getString('user_uuid');
    final authToken = sharedPreferences.getString('auth_token');

    if (authToken == null || currentUserUuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User authentication token is missing.')),
      );
      return;
    }

    bool newStatus = !_followStatusMap[userUuid]!;
    int updatedFollowerCount = newStatus ? 1 : 0;

    final url =
        Uri.parse('$baseUrl/updateFollowStatus/$userUuid/$currentUserUuid');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': newStatus ? 'follow' : 'unfollow',
          'follower': updatedFollowerCount,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _followStatusMap[userUuid] = newStatus;
        _followerCountMap[userUuid] = updatedFollowerCount;
        notifyListeners();
      } else {
        print('Error updating follow status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling follow status: $e');
    }
  }
}
