// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/widgets/post_preview.dart';
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
      Navigator.push(
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

        if (postDataList != null) {
          setState(() {
            postData = postDataList;
          });
        }
      } else {
        setState(() {
          postData = [];
        });
        _handleError(response);
      }
    } catch (e) {
      setState(() {
        postData = [];
      });
      print('Error fetching Post data: $e');
    }
  }

  void _handleError(http.Response response) {
    if (response.statusCode == 500) {
      print(response.body);
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
    if (postData.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: const Center(
          child: Text(
            'No Post Found!',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

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
        final imageUrl = '$imageBaseUrl${postData[index]['post_url']}';

        return AspectRatio(
          aspectRatio: 1,
          child: imageUrl.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PostCardPreview(
                                  postUuid: postData[index]['post_uuid'],
                                )));
                  },
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        ),
                      );
                    },
                  ),
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
