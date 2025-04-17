// ignore_for_file: use_build_context_synchronously, avoid_print
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/services/add_post_service.dart';
import 'package:quick_social/widgets/layout/app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/widgets/layout/responsive_padding.dart';
import 'package:quick_social/widgets/post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  Map<String, dynamic> data = {};
  bool _isLoading = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PostService postService = PostService();

  @override
  void initState() {
    super.initState();
    postService.createPost;
    getPosts();
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> getPosts() async {
    final url = Uri.parse('$baseUrl/getposts');
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');

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
      appBar: CustomAppBar(
          onPressed: () => _scaffoldKey.currentState?.openDrawer()),
      drawer: Drawer(
        shape: const LinearBorder(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: MediaQuery.of(context).size.height * 0.024,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
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
                      return PostCard(
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
