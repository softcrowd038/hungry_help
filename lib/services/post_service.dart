// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DeletePostService {
  Future<String> deletePostByPostUUId(
      BuildContext context, String postUuid) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final url = Uri.parse('$baseUrl/deletepostbypost_uuid/$postUuid');

    final List<String> errors = [];

    try {
      final response = await http
          .delete(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          await deleteLikeStatusByPostUUid(context, postUuid);
        } catch (e) {
          errors.add('Failed to delete likes: $e');
        }

        try {
          await deleteCommentByPostUUID(context, postUuid);
        } catch (e) {
          errors.add('Failed to delete comments: $e');
        }

        if (errors.isEmpty) {
          return 'Post and associated data deleted successfully.';
        } else {
          return 'Post deleted with some issues: ${errors.join(', ')}';
        }
      } else {
        throw Exception(
            'Failed to delete post. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting post: $e');
    }
  }

  Future<void> deleteLikeStatusByPostUUid(
      BuildContext context, String postUuid) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final url = Uri.parse('$baseUrl/deletelikesbypostuuid/$postUuid');

    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $authToken'});

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to delete likes. Status: ${response.statusCode}');
    }
  }

  Future<void> deleteCommentByPostUUID(
      BuildContext context, String postUuid) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final url = Uri.parse('$baseUrl/deletecommentsbypostuuid/$postUuid');

    final response =
        await http.delete(url, headers: {'Authorization': 'Bearer $authToken'});

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
          'Failed to delete comments. Status: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> deleteCommentByCommentUUID(
      BuildContext context, String comment_uuid) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final url = Uri.parse('$baseUrl/deletecommentsbycommentuuid/$comment_uuid');

    try {
      final response = await http
          .delete(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (context.mounted) {}
        return jsonDecode(response.body);
      } else {
        if (context.mounted) {
          print('Error: ${response.body}');
        }
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      if (context.mounted) {
        print('Error: $e');
      }
      throw Exception('Error: $e');
    }
  }
}
