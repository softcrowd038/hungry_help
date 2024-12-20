// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/widgets/comment_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CommentsBottomSheet extends StatefulWidget {
  final String? postUuid;
  const CommentsBottomSheet({super.key, required this.postUuid});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  List<String> _comments = [];
  List<String> _uuid = [];

  final TextEditingController _commentText = TextEditingController();

  @override
  void initState() {
    super.initState();
    initalizeData();
  }

  void initalizeData() async {
    await getCommentsByPostUUID();
  }

  Future<void> postComment(
    BuildContext context,
  ) async {
    if (_commentText.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment cannot be empty')),
      );
      return;
    }

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

    final Uri url = Uri.parse('$baseUrl/createcomment');

    final Map<String, dynamic> body = {
      'post_uuid': widget.postUuid,
      'user_uuid': uuid,
      'comment': _commentText.text,
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
        print(jsonResponse['message'] ?? 'Comment posted successfully.');
        Navigator.pop(context);
        setState(() {
          _commentText.clear();
        });
        await getCommentsByPostUUID();
      } else {
        final jsonResponse = json.decode(response.body);
        final message = jsonResponse['message'] ?? 'Failed to post comment';
        print('Error posting comment: ${response.statusCode} - $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $message')),
        );
      }
    } catch (e) {
      print('Error posting comment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while posting your comment.')),
      );
    }
  }

  Future<void> getCommentsByPostUUID() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final url = Uri.parse('$baseUrl/getcommentsbypostuuid/${widget.postUuid}');

    if (authToken == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] is List) {
          List<dynamic> commentData = data['data'];
          print(commentData);
          setState(() {
            _comments =
                commentData.map<String>((item) => item['comment']).toList();
            _uuid =
                commentData.map<String>((item) => item['user_uuid']).toList();
          });
          print(_comments);
        } else {
          throw Exception('Invalid response structure or missing data.');
        }
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      throw Exception('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 64),
          child: Container(
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            padding: const EdgeInsets.only(bottom: 64),
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: _comments.isEmpty
                ? const Center(child: Text('No comments to display.'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _comments.length,
                    itemBuilder: (_, index) {
                      return index == 0
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: CommentTile(
                                comment: _comments[index],
                                uuid: _uuid[index],
                              ),
                            )
                          : CommentTile(
                              comment: _comments[index],
                              uuid: _uuid[index],
                            );
                    },
                  ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: _header(theme),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _commentTextField(theme),
        ),
      ],
    );
  }

  Widget _header(ThemeData theme) {
    return SizedBox(
      height: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {},
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: theme.dividerColor.withAlpha(100),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Comments',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentTextField(ThemeData theme) {
    return Container(
      color: theme.colorScheme.secondaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _commentText,
              autofocus: true,
              onSubmitted: (value) {
                postComment(
                  context,
                );
              },
              decoration: InputDecoration(
                hintText: 'Write your comment',
                filled: true,
                isDense: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: () {
              if (_commentText.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Comment cannot be empty')),
                );
                return;
              }
              postComment(
                context,
              );
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
