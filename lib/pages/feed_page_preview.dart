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
  Map<String, dynamic> data = {};
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        setState(() {
          data = responseData;
          _isLoading = false;
        });
      } else if (response.statusCode == 404) {
        setState(() {
          data = {'data': []};
          _isLoading = false;
        });
      } else {
        throw Exception('Error: ${response.body}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      setState(() {
        data = {'data': []};
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
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
                    Navigator.push(
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
          : data['data'] == null || data['data'].isEmpty
              ? Center(
                  child: Text(
                    'No one has posted yet.',
                    style: theme.textTheme.bodyLarge,
                  ),
                )
              : ResponsivePadding(
                  child: ListView.builder(
                    itemCount: data['data'] != null ? data['data'].length : 0,
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
