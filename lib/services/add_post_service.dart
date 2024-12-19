// Updated PostService
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/models/posts_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostService {
  Future<PostModel> createPost({
    required String uuid,
    required String title,
    required String description,
    required DateTime postDate,
    required String postTime,
    required String type,
    required int likes,
    required File? file,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    final url = Uri.parse('$baseUrl/create');

    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $authToken';
      request.fields['uuid'] = uuid;
      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['post_date'] = postDate.toIso8601String();
      request.fields['post_time'] = postTime;
      request.fields['type'] = type;
      request.fields['likes'] = likes.toString();

      if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'post_url',
            file.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decodedResponse = jsonDecode(response.body);
        return PostModel.fromJson(decodedResponse['data']);
      } else {
        throw Exception('Failed to create post: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<dynamic>> getPost(String postUuid) async {
    final url = Uri.parse('$baseUrl/getposts');

    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final postDataList = jsonDecode(response.body)['data'];
        if (postDataList != null) {
          final postData = postDataList
              .where((post) => post['post_uuid'] == postUuid)
              .toList();
          return postData;
        } else {
          throw Exception('No posts found.');
        }
      } else {
        throw Exception('Error fetching post data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching post data: $e');
    }
  }

  Future<void> postLikeStatus(BuildContext context, String postUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final uuid = prefs.getString('user_uuid');

    if (token == null || uuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User authentication token or UUID is missing.')),
      );
      return;
    }

    final Uri url = Uri.parse('$baseUrl/postlikestatus');

    final Map<String, dynamic> body = {
      'uuid': uuid,
      'post_uuid': postUuid,
      'status': 'inactive', // Default status
      'likes': 0 // Default like count
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
        final jsonResponse = json.decode(response.body);
        // Handle successful response (if needed)
      } else {
        final jsonResponse = json.decode(response.body);
        final message = jsonResponse['message'] ?? 'Failed to post like status';
        print('Error posting like status: ${response.statusCode} - $message');
      }
    } catch (e) {
      print('Error posting like status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while posting like status.')),
      );
    }
  }

  // Method to post follow status
  Future<void> postFollowStatus(BuildContext context, String userUUID) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final uuid = prefs.getString('user_uuid');

    if (token == null || uuid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User authentication token or UUID is missing.')),
      );
      return;
    }

    final Uri url = Uri.parse('$baseUrl/addfollower');

    final Map<String, dynamic> body = {
      'account_uuid': userUUID,
      'followed_by_uuid': uuid,
      'status': 'unfollow', // Default status
      'follower': 0, // Default follower count
      'following': 0, // Default following count
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
        final jsonResponse = json.decode(response.body);
        // Handle successful response (if needed)
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body);
        print(
            'Validation error: ${jsonResponse['message'] ?? 'Invalid request data'}');
      } else if (response.statusCode == 500) {
        print('Internal server error');
      } else {
        final jsonResponse = json.decode(response.body);
        final message =
            jsonResponse['message'] ?? 'Failed to create follower status';
        print(
            'Error creating follower status: ${response.statusCode} - $message');
      }
    } catch (e) {
      print('Error creating follower status: $e');
    }
  }
}
