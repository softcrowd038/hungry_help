// ignore_for_file: avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/models/user_model.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/provider/user_provider.dart';
import 'package:quick_social/services/add_post_service.dart';
import 'package:quick_social/services/post_service.dart';
import 'package:quick_social/widgets/comment_post_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class PostCardPreview extends StatefulWidget {
  final String postUuid;
  const PostCardPreview({
    super.key,
    required this.postUuid,
  });

  @override
  State<PostCardPreview> createState() => _PostCardPreviewState();
}

class _PostCardPreviewState extends State<PostCardPreview> {
  List<dynamic> postData = [];
  List<String> uuids = [];
  bool isLoading = false;
  bool isDeleteVisible = false;
  UserAccount? profile;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final uuid = sharedPreferences.getString('user_uuid');

    if (uuid == null) {
      print('User UUID is missing');
      return;
    }

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      userProvider.fetchUserProfile(uuid);
      final fetchedProfile = userProvider.getUser(uuid);

      if (mounted) {
        setState(() {
          profile = fetchedProfile;
        });
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }

    await _fetchPostData();
  }

  Future<void> _fetchPostData() async {
    try {
      final postService = PostService();
      postData = await postService.getPost(widget.postUuid);
      print(postData);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _mobileCard(context);
              },
            ),
            CommentsPostPreview(postUuid: widget.postUuid)
          ],
        ),
      ),
    );
  }

  Widget _mobileCard(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.errorMessage != null) {
      return Center(child: Text('Error: ${userProvider.errorMessage}'));
    }

    if (profile == null) {
      return const Center(
        child: Text('Loading profile...'),
      );
    }

    final userProfile = profile!.userProfile;

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
                  backgroundImage: profile!.userProfile.imageurl != null
                      ? NetworkImage('$imageBaseUrl${userProfile.imageurl}')
                      : const AssetImage('assets/placeholder_avatar.png'),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isLoading
                        ? Shimmer(
                            duration: const Duration(seconds: 2),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.015,
                              width: MediaQuery.of(context).size.width * 0.15,
                              color: Colors.grey,
                            ),
                          )
                        : Text(
                            userProfile.username ?? 'User Name',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                    isLoading
                        ? Shimmer(
                            duration: const Duration(seconds: 2),
                            child: Container(
                              height:
                                  MediaQuery.of(context).size.height * 0.015,
                              width: MediaQuery.of(context).size.width * 0.10,
                              color: Colors.grey,
                            ),
                          )
                        : Text(
                            getTimeDifference(
                                post['post_date'], post['post_time']),
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.014),
                          ),
                  ],
                ),
                trailing: GestureDetector(
                    onTap: () {
                      setState(() {
                        isDeleteVisible = !isDeleteVisible;
                      });
                    },
                    child: const Icon(Icons.more_vert))),
            if (isDeleteVisible)
              GestureDetector(
                onTap: () async {
                  final deleteService = DeletePostService();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomePage()));

                  try {
                    final response = await deleteService.deletePostByPostUUId(
                        context, widget.postUuid);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post deleted')),
                    );
                  } catch (e) {
                    print('Error deleting Post: $e');
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04,
                    vertical: MediaQuery.of(context).size.height * 0.01,
                  ),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.07,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * 0.01,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Delete',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Post Content
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
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.height * 0.016,
                    ),
                    child: Divider(
                        height: MediaQuery.of(context).size.height * 0.004),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}
