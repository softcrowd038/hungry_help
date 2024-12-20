// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/data/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LikeStatusProvider with ChangeNotifier {
  final Map<String, bool> _likeStatusMap = {};
  final Map<String, int> _likeCountMap = {};
  final Map<String, int> _totalLikesMap = {};

  bool isLiked(String postUuid) => _likeStatusMap[postUuid] ?? false;
  int likeCount(String postUuid) => _likeCountMap[postUuid] ?? 0;
  int totalLikes(String postUuid) => _totalLikesMap[postUuid] ?? 0;

  Future<void> fetchLikeStatus(String postUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final uuid = prefs.getString('user_uuid');

    if (token == null || uuid == null) return;

    final Uri url =
        Uri.parse('$baseUrl/getLikesbyuuidandpostuuid/$uuid/$postUuid');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          final statusData = data['data'].first;
          _likeStatusMap[postUuid] =
              (statusData['status'] ?? 'inactive') == 'active';
          _likeCountMap[postUuid] = statusData['likes'] ?? 0;
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching like status: $e');
    }
  }

  Future<void> getTotalLikes(String postUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('User authentication token is missing.');
    }

    final Uri url = Uri.parse('$baseUrl/sum-likes/$postUuid');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        _totalLikesMap[postUuid] = jsonResponse['totalLikes'];
        notifyListeners();
      } else {
        final jsonResponse = json.decode(response.body);
        final message =
            jsonResponse['message'] ?? 'Failed to fetch total likes';
        throw Exception(
            'Error fetching total likes: ${response.statusCode} - $message');
      }
    } catch (e) {
      print('Error fetching total likes: $e');
    }
  }

  Future<void> toggleLikeStatus(BuildContext context, String postUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final uuid = prefs.getString('user_uuid');

    if (token == null || uuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User authentication token is missing.')),
      );
      return;
    }

    final currentStatus = _likeStatusMap[postUuid] ?? false;
    final newStatus = !currentStatus;
    final newLikes = newStatus
        ? (_likeCountMap[postUuid] ?? 0) + 1
        : (_likeCountMap[postUuid] ?? 1) - 1;

    final Uri url =
        Uri.parse('$baseUrl/updateLikestatusbyuuidandpostuuid/$uuid/$postUuid');

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {'status': newStatus ? 'active' : 'inactive', 'likes': newLikes}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _likeStatusMap[postUuid] = newStatus;
        _likeCountMap[postUuid] = newLikes;

        await getTotalLikes(postUuid);
      } else {
        print('Error toggling like status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling like status: $e');
    }
  }
}
