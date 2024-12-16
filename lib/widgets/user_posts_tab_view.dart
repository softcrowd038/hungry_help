import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class UserPostsTabView extends StatefulWidget {
  const UserPostsTabView({
    super.key,
    required this.uuid,
  });

  final String? uuid;

  @override
  State<UserPostsTabView> createState() => _UserPostsTabViewState();
}

class _UserPostsTabViewState extends State<UserPostsTabView> {
  List<dynamic> postData = [];
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    if (mounted) {
      await getPost();
    }
  }

  Future<void> getPost() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');
    final url = Uri.parse('$baseUrl/getpostsbyid/$uuid');

    if (authToken == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authToken'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final postDataList = jsonDecode(response.body)['data'];
        print(postDataList);
        if (postDataList != null) {
          setState(() {
            postData = postDataList;
          });
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      print('Error fetching Post data: $e');
    }
  }

  void _handleError(http.Response response) {
    if (response.statusCode == 500) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      print('Error: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _postsGridView(context),
      ],
    );
  }

  Widget _postsGridView(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      shrinkWrap: true,
      itemCount: postData.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, index) {
        final imageUrl =
            'http://192.168.1.3:8080/${postData[index]['post_url']}';

        return AspectRatio(
          aspectRatio: 1,
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                )
              : Shimmer(
                  duration: const Duration(seconds: 2),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      color: Colors.grey,
                    ),
                  ),
                ),
        );
      },
    );
  }
}
