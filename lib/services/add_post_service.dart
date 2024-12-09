import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:quick_social/data/app_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPostService {
  Future<dynamic> createPost({
    required String uuid,
    required String title,
    required String description,
    required String postDate,
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
      request.fields['post_date'] = postDate;
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
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create post: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
