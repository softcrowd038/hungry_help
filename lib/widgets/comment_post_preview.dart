// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/widgets/comment_tile_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CommentsPostPreview extends StatefulWidget {
  final String? postUuid;
  const CommentsPostPreview({super.key, required this.postUuid});

  @override
  State<CommentsPostPreview> createState() => _CommentsPostPreviewState();
}

class _CommentsPostPreviewState extends State<CommentsPostPreview> {
  List<String> _comments = [];
  List<String> _commentsUUID = [];
  List<String> _uuid = [];

  @override
  void initState() {
    super.initState();
    initalizeData();
  }

  void initalizeData() async {
    await getCommentsByPostUUID();
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
            _commentsUUID = commentData
                .map<String>((item) => item['comment_uuid'])
                .toList();
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
            height: MediaQuery.of(context).size.height * 0.70,
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
                              child: CommentTilePreview(
                                comment: _comments[index],
                                uuid: _uuid[index],
                                commentuuid: _commentsUUID[index],
                              ),
                            )
                          : CommentTilePreview(
                              comment: _comments[index],
                              uuid: _uuid[index],
                              commentuuid: _commentsUUID[index],
                            );
                    },
                  ),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: _header(theme),
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
}
