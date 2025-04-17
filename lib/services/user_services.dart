// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/models/user_model.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserApiService {
  Future<UserAccount?> getUserProfile(String uuid) async {
    final url = Uri.parse('$baseUrl/profile/$uuid');

    try {
      final response = await http.get(
        url,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        return UserAccount(
          success: responseData['success'],
          userProfile: UserProfile.fromJson(responseData['userProfile']),
        );
      } else {
        throw Exception(
            'Failed to load user profile. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');
    final url = Uri.parse('$baseUrl/deleteprofile/$uuid');

    List<String> errors = [];

    try {
      final response = await http
          .delete(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (context.mounted) {
          try {
            await deleteAccountPost(context);
          } catch (e) {
            errors.add('Failed to delete posts: $e');
          }

          try {
            await deleteAccountLikes(context);
          } catch (e) {
            errors.add('Failed to delete likes: $e');
          }

          try {
            await deleteAccountComments(context);
          } catch (e) {
            errors.add('Failed to delete comments: $e');
          }

          try {
            await deleteAccountFollowers(context);
          } catch (e) {
            errors.add('Failed to delete followers: $e');
          }

          if (errors.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account deleted successfully')),
            );
          } else {
            print('Account deleted with some errors:\n${errors.join('\n')}');
          }
        }
      } else {
        throw Exception(
            'Failed to delete account. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (context.mounted) {
        print('Error: $e');
      }
    }
  }

  Future<List<dynamic>> deleteUser(BuildContext context) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');
    final url = Uri.parse('$baseUrl/deleteuser/$uuid');

    try {
      final response = await http
          .delete(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 201 || response.statusCode == 200) {
        await deleteAccount(context);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );

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

  Future<List<dynamic>> deleteAccountPost(BuildContext context) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');
    final url = Uri.parse('$baseUrl/postbyuuid/$uuid');

    try {
      final response = await http
          .delete(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 201 || response.statusCode == 200) {
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

  Future<List<dynamic>> deleteAccountLikes(BuildContext context) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');
    final url = Uri.parse('$baseUrl/deletelikestatus/$uuid');

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

  Future<List<dynamic>> deleteAccountFollowers(BuildContext context) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');
    final url = Uri.parse('$baseUrl/deletefollower/$uuid');

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

  Future<List<dynamic>> deleteAccountComments(BuildContext context) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');
    final url = Uri.parse('$baseUrl/deletecomment/$uuid');

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
