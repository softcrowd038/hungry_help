// ignore_for_file: use_build_context_synchronously, avoid_print, unnecessary_null_comparison

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/provider/post_provider.dart';
import 'package:quick_social/widgets/layout/button_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostPreview extends StatefulWidget {
  const PostPreview({super.key});
  @override
  State<StatefulWidget> createState() => _PostPreview();
}

class _PostPreview extends State<PostPreview> {
  Map<String, dynamic> userProfile = {};

  @override
  void initState() {
    super.initState();
    getProfileData();
  }

  Future<void> getProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final authtoken = prefs.getString('auth_token');
    final uuid = prefs.getString('user_uuid');
    final url = Uri.parse('$baseUrl/profile/$uuid');

    try {
      final response =
          await http.get(url, headers: {'Authorization': 'Bearer $authtoken'});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true &&
            responseData['userProfile'] != null) {
          setState(() {
            userProfile = responseData['userProfile'];
          });
        } else {
          throw Exception('Invalid response structure: ${response.body}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> createPost() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final uuid = prefs.getString('user_uuid');

      final postProvider = Provider.of<PostProvider>(context, listen: false);

      if (token == null || uuid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User authentication token or UUID is missing.'),
          ),
        );
        return;
      }

      final String authToken = token;
      final url = Uri.parse('$baseUrl/create');

      var request = http.MultipartRequest('POST', url);
      request.fields['uuid'] = uuid;
      request.fields['title'] = postProvider.title!;
      request.fields['description'] = postProvider.description!;
      request.fields['post_date'] = _getCurrentDate();
      request.fields['post_time'] = _getCurrentTime();
      request.fields['type'] = postProvider.type!;
      request.fields['likes'] = '0';

      if (postProvider.postUrl!.path != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'post_url',
          postProvider.postUrl!.path,
        ));
      }

      request.headers['Authorization'] = 'Bearer $authToken';

      var response = await request.send();

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseData.body);

        print('Post created successfully: $jsonResponse');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        final responseData = await http.Response.fromStream(response);
        final jsonResponse = json.decode(responseData.body);
        final message = jsonResponse['message'] ??
            'Failed to create post. Please try again.';
        print('Failed to create post: ${response.statusCode} - $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      print('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {}
  }

  String _getCurrentDate() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return formattedDate;
  }

  String _getCurrentTime() {
    final DateTime now = DateTime.now();
    final String formattedTime =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Review Your Post',
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          MediaQuery.of(context).size.height * 0.025),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 5,
                            offset: const Offset(1, 1))
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.height * 0.015,
                          ),
                          if (userProfile['imageurl'] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  MediaQuery.of(context).size.height * 0.15),
                              child: Image.network(
                                '$imageBaseUrl${userProfile['imageurl']}',
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                                width:
                                    MediaQuery.of(context).size.height * 0.07,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[
                                        300], // Placeholder background color
                                    child: Icon(
                                      Icons.person, // Fallback icon
                                      size: MediaQuery.of(context).size.height *
                                          0.04,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                          SizedBox(
                            width: MediaQuery.of(context).size.height * 0.015,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '@${userProfile['username']}',
                                style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.018,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Posted xx mins ago',
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.height *
                                      0.014,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.height * 0.015,
                            top: MediaQuery.of(context).size.height * 0.015),
                        child: Text(
                          postProvider.title!,
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.022,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.height * 0.050,
                        ),
                        child: Text(
                          postProvider.description!,
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.016,
                              fontWeight: FontWeight.w100),
                        ),
                      ),
                      if (postProvider.type == 'image')
                        FutureBuilder<Size>(
                          future:
                              _getImageSize(File(postProvider.postUrl!.path)),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.025),
                                            bottomRight: Radius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.025))),
                                    child: AspectRatio(
                                      aspectRatio: 1 / 1,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.025),
                                            bottomRight: Radius.circular(
                                                MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.025)),
                                        child: Image.file(
                                          File(postProvider.postUrl!.path),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await createPost();
                },
                child: const ButtonWidget(
                  borderRadius: 0.06,
                  height: 0.06,
                  width: 1,
                  text: 'POST',
                  textFontSize: 0.022,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Size> _getImageSize(File imageFile) async {
  final completer = Completer<Size>();
  final image = Image.file(imageFile);
  image.image.resolve(const ImageConfiguration()).addListener(
    ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(
          Size(info.image.width.toDouble(), info.image.height.toDouble()));
    }),
  );
  return completer.future;
}
