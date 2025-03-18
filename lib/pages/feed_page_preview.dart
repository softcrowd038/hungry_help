// ignore_for_file: use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/services/add_post_service.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/widgets/layout/responsive_padding.dart';
import 'package:quick_social/widgets/post_card_preview.dart';

class FeedPagePreview extends StatefulWidget {
  const FeedPagePreview({super.key});

  @override
  State<FeedPagePreview> createState() => _FeedPagePreviewState();
}

class _FeedPagePreviewState extends State<FeedPagePreview>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic> data = {'data': []};
  bool _isLoading = true;
  bool _hasError = false;

  PostService postService = PostService();

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  Future<void> getPosts() async {
    final url = Uri.parse('$baseUrl/getposts');

    try {
      final response = await http.get(url);

      if (!mounted) return;
      print(response.statusCode);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              data = responseData;
              _isLoading = false;
              _hasError = false;
            });
          }
        });
      } else {
        _isLoading = false;
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      _isLoading = false;
      print('Error fetching posts: $e ');
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.height * 0.009),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: const AssetImage('assets/images/logo6.png'),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.1,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.height * 0.015,
                    ),
                    Text(
                      'Akshay Patra',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.022,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                  },
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.050,
                    width: MediaQuery.of(context).size.height * 0.100,
                    decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height * 0.0080)),
                    child: Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.018),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? Center(
                  child: Text(
                    'Failed to load posts. Please try again later.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : data['data'].isEmpty
                  ? Center(
                      child: Text(
                        'No one has posted yet.',
                        style: theme.textTheme.bodyLarge,
                      ),
                    )
                  : ResponsivePadding(
                      child: ListView.builder(
                        itemCount: data['data'].length,
                        itemBuilder: (_, index) {
                          var post = data['data'][index];
                          return PostCardLoginPreview(
                            uuid: post['uuid'],
                            postUuid: post['post_uuid'],
                            initialCount: post['likes'],
                          );
                        },
                      ),
                    ),
    );
  }
}
