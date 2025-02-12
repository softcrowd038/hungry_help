// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quick_social/data/app_data.dart';

class LikeService {
  Future<void> postLikeStatus(BuildContext context, String postUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final uuid = prefs.getString('user_uuid');

    if (token == null || uuid == null) {
      _showErrorSnackBar(
          context, 'User authentication token or UUID is missing.');
      return;
    }

    final Uri url = Uri.parse('$baseUrl/postlikestatus');

    final body = {
      'uuid': uuid,
      'post_uuid': postUuid,
      'status': 'inactive',
      'likes': 0,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        print('Like status successfully posted.');
      } else {
        final jsonResponse = json.decode(response.body);
        final message =
            jsonResponse['message'] ?? 'Failed to post like status.';
        print('Error posting like status: ${response.statusCode} - $message');
      }
    } catch (e) {
      print('Error posting like status: $e');
      _showErrorSnackBar(
          context, 'An error occurred while posting like status.');
    }
  }

  Future<Map<String, dynamic>> getLikeStatus(
      BuildContext context, String postUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final uuid = prefs.getString('user_uuid');

    if (authToken == null || uuid == null) {
      _showErrorSnackBar(
          context, 'User authentication token or UUID is missing.');
      return {};
    }

    final Uri url =
        Uri.parse('$baseUrl/getLikesbyuuidandpostuuid/$uuid/$postUuid');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'].first ?? {};
        } else {
          throw Exception('Invalid response structure or missing data.');
        }
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching like status: $e');
      return {};
    }
  }

  Future<void> toggleLikeStatus(BuildContext context, String postUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final uuid = prefs.getString('user_uuid');

    if (token == null || uuid == null) {
      _showErrorSnackBar(
          context, 'User authentication token or UUID is missing.');
      return;
    }

    final Uri url =
        Uri.parse('$baseUrl/updateLikestatusbyuuidandpostuuid/$uuid/$postUuid');

    final currentStatus = await getLikeStatus(context, postUuid);
    final isLiked = (currentStatus['status'] ?? 'inactive') == 'active';
    final currentLikes = currentStatus['likes'] ?? 0;

    final newStatus = isLiked ? 'inactive' : 'active';
    final newLikes = isLiked ? currentLikes - 1 : currentLikes + 1;

    try {
      final response = await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': newStatus, 'likes': newLikes}),
      );

      if (response.statusCode == 200) {
        print('Like status updated successfully.');
      } else {
        print('Failed to update like status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling like status: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
