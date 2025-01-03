// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/provider/follow_status.dart';
import 'package:quick_social/provider/user_provider.dart';
import 'package:quick_social/services/add_post_service.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PostCardLoginPreview extends StatefulWidget {
  final String uuid;
  final String postUuid;
  final int initialCount;
  const PostCardLoginPreview(
      {super.key,
      required this.uuid,
      required this.postUuid,
      required this.initialCount});

  @override
  State<PostCardLoginPreview> createState() => _PostCardLoginPreviewState();
}

class _PostCardLoginPreviewState extends State<PostCardLoginPreview> {
  List<dynamic> postData = [];
  List<String> uuids = [];
  bool isLoading = true;
  String? status;

  late FollowStatusProvider followStatusProvider;

  @override
  void initState() {
    super.initState();
    _initializeData();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _initializeData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserProfile(widget.uuid);
    });
    await _fetchPostData();
  }

  final postService = PostService();

  Future<void> _fetchPostData() async {
    try {
      final postService = PostService();
      postData = await postService.getPost(widget.postUuid);
    } catch (e) {
      print('Error fetching post data: $e');
    }
  }

  String getTimeDifference(String postDate, String postTime) {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final DateFormat timeFormat = DateFormat('HH:mm:ss');

    DateTime postDateParsed =
        dateFormat.parse('${DateTime.parse(postDate).toLocal()}');
    DateTime postTimeParsed = timeFormat.parse(postTime);

    DateTime postDateTime = DateTime(
      postDateParsed.year,
      postDateParsed.month,
      postDateParsed.day,
      postTimeParsed.hour,
      postTimeParsed.minute,
      postTimeParsed.second,
    );

    DateTime now = DateTime.now();
    DateTime currentDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );

    print('currentDateTime : $currentDateTime');

    final Duration difference = currentDateTime.difference(postDateTime);
    print('difference : $difference');
    if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showLoginDialog(BuildContext context, String title, String message) {
    showDialog(
        context: context,
        builder: (_) => GiffyDialog(
              giffy: Image.network(
                  'https://cdn.dribbble.com/users/1939393/screenshots/6392286/dribbble-404-error.gif'),
              title: Text(title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height * 0.022,
                      fontWeight: FontWeight.w600)),
              entryAnimation: EntryAnimation.bottom,
              content: Text(
                message,
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.018),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()));
                        },
                        child: Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.016),
                        )),
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Not Now',
                          style: TextStyle(
                              color: Colors.red,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.016),
                        )),
                  ],
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _mobileCard(context);
      },
    );
  }

  Widget _mobileCard(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.errorMessage != null) {
      return Center(child: Text('Error: ${userProvider.errorMessage}'));
    }

    final profile = userProvider.getUser(widget.uuid);
    if (profile == null) {
      return const Center(child: Text(''));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: postData.length,
      itemBuilder: (context, index) {
        final post = postData[index];
        bool isLoading = userProvider.isLoading || postData.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
                leading: CircleAvatar(
                  backgroundImage: profile.userProfile.imageurl != null
                      ? NetworkImage(
                          '$imageBaseUrl${profile.userProfile.imageurl}',
                        )
                      : null,
                  child: profile.userProfile.imageurl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.userProfile.username ?? 'Loading...',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      getTimeDifference(post['post_date'], post['post_time']),
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.014),
                    ),
                  ],
                ),
                trailing: GestureDetector(
                    onTap: () {
                      _showLoginDialog(context, 'Want to Access More Features',
                          'Login to Unlock this feature');
                    },
                    child: const Icon(Icons.more_vert))),
            if (!isLoading) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.015,
                        left: MediaQuery.of(context).size.height * 0.015,
                        right: MediaQuery.of(context).size.height * 0.015),
                    child: isLoading
                        ? Shimmer(
                            duration: const Duration(seconds: 2),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.018,
                              width: MediaQuery.of(context).size.width * 0.20,
                              color: Colors.grey,
                            ))
                        : Text(
                            post['title'],
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.018,
                                fontWeight: FontWeight.bold),
                          ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.015,
                        left: MediaQuery.of(context).size.height * 0.015,
                        right: MediaQuery.of(context).size.height * 0.015),
                    child: isLoading
                        ? Shimmer(
                            duration: const Duration(seconds: 2),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.015,
                              width: MediaQuery.of(context).size.width * 0.30,
                              color: Colors.grey,
                            ))
                        : Text(
                            post['description'],
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.015,
                                color: Colors.grey),
                          ),
                  ),
                  AspectRatio(
                    aspectRatio: 1 / 1,
                    child: isLoading
                        ? Padding(
                            padding: EdgeInsets.all(
                                MediaQuery.of(context).size.height * 0.015),
                            child: Shimmer(
                              duration: const Duration(seconds: 2),
                              child: Container(
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.height * 0.015),
                            child: Image.network(
                              '$imageBaseUrl${post['post_url']}',
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Shimmer(
                                    duration: const Duration(seconds: 2),
                                    child: Container(
                                      color: const Color.fromARGB(
                                          255, 196, 196, 196),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const AspectRatio(
                                  aspectRatio: 1 / 1,
                                  child: Icon(Icons.error),
                                );
                              },
                            ),
                          ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.favorite_border,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              _showLoginDialog(context, 'Want to Like',
                                  'Login to Unlock this feature');
                            },
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment),
                        onPressed: () {
                          _showLoginDialog(context, 'Want to Comment',
                              'Login to Unlock this feature');
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.height * 0.016,
                    ),
                    child: Divider(
                        height: MediaQuery.of(context).size.height * 0.004),
                  )
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
