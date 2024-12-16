// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/widgets/comments_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer_animation/shimmer_animation.dart';

class PostCard extends StatefulWidget {
  final String uuid;
  final String postUuid;
  final int initialCount;
  const PostCard(
      {super.key,
      required this.uuid,
      required this.postUuid,
      required this.initialCount});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Map<String, dynamic> profileData = {};
  List<dynamic> postData = [];
  List<String> uuids = [];
  bool isLoading = true;
  String? status;
  int? _likesCount;
  int? _totalLikesCount;
  int? _followerCount;
  int? _initialfollowerCount;
  bool? _isLiked;
  bool? _isFollowing;
  final GlobalKey<_PostCardState> _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeData();
    setState(() {
      isLoading = false;
    });
    _likesCount = widget.initialCount;
    _isLiked = false;
    _isFollowing = false;
    _followerCount = _initialfollowerCount;
  }

  Future<void> _initializeData() async {
    await getFollowerInitialCount();
    await postFollowStatus(context, widget.uuid);
    await getUsers(widget.uuid);
    await getPost(widget.postUuid);
    await postLikeStatus(context, widget.postUuid);
    await getLikeStatus();
    await getTotalLikes(widget.postUuid);
  }

  Future<void> getUsers(String uuid) async {
    final url = Uri.parse('$baseUrl/profile/$uuid');
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');

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
        final profile = jsonDecode(response.body)['userProfile'];
        if (profile != null) {
          setState(() {
            profileData[uuid] = profile;
            uuids.add(uuid);
          });
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> getPost(String postUuid) async {
    final url = Uri.parse('$baseUrl/getposts');
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');

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
        if (postDataList != null) {
          setState(() {
            postData = postDataList
                .where((post) => post['post_uuid'] == widget.postUuid)
                .toList();
            uuids.add(widget.postUuid);
          });
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      print('Error fetching Post data: $e');
    }
  }

  Future<void> postLikeStatus(BuildContext context, String postUuid) async {
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

    final Uri url = Uri.parse('$baseUrl/postlikestatus');

    final Map<String, dynamic> body = {
      'uuid': uuid,
      'post_uuid': postUuid,
      'status': 'inactive',
      'likes': 0
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
        print(jsonResponse['message'] ?? 'Like status posted successfully.');
      } else {
        final jsonResponse = json.decode(response.body);
        final message = jsonResponse['message'] ?? 'Failed to post like status';
        print('Error posting like status: ${response.statusCode} - $message');
      }
    } catch (e) {
      print('Error posting like status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while posting like status.')),
      );
    }
  }

  Future<void> getLikeStatus() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');

    final url = Uri.parse(
        '$baseUrl/getLikesbyuuidandpostuuid/$uuid/${widget.postUuid}');

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
          final statusData = data['data'].first;
          setState(() {
            status = statusData['status'] ?? 'inactive';
            _isLiked = status == 'active';
          });
        } else {
          throw Exception('Invalid response structure or missing data.');
        }
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching like status: $e');
      throw Exception('Error: $e');
    }
  }

  void refreshScreen() {
    _key.currentState?.initState();
  }

  Future<void> toggleLikeStatus() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final uuid = sharedPreferences.getString('user_uuid');
    final postUuid = widget.postUuid;

    if (uuid == null) {
      print('Missing required data: uuid or postUuid.');
      return;
    }

    final newStatus = _isLiked! ? 'inactive' : 'active';
    int newLikes = _likesCount!;
    int newTotalLikes = _totalLikesCount!;
    if (_isLiked!) {
      newLikes--;
      newTotalLikes--;
    } else {
      newLikes++;
      newTotalLikes++;
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/updateLikestatusbyuuidandpostuuid/$uuid/$postUuid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_AUTH_TOKEN_HERE',
        },
        body: json.encode({'status': newStatus, 'likes': newLikes}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isLiked = !_isLiked!;
          _likesCount = newLikes;
          _totalLikesCount = newTotalLikes;
        });
      } else {
        print('Failed to update like status.');
      }
    } catch (e) {
      print('Error toggling like status: $e');
    }
  }

  Future<void> getFollowerInitialCount() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');

    final url = Uri.parse('$baseUrl/follower/${widget.uuid}/$uuid');

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
          final statusData = data['data'].first;
          setState(() {
            status = statusData['status'] ?? 'unfollow';
            _isFollowing = status == 'follow';
            _initialfollowerCount = statusData['followers'];
          });
        } else {
          throw Exception('Invalid response structure or missing data.');
        }
      } else {
        throw Exception('Unexpected status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching like status: $e');
      throw Exception('Error: $e');
    }
  }

  Future<void> toggleFollowStatus(BuildContext context) async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    final followedByUuid = sharedPreferences.getString('user_uuid');
    final token = sharedPreferences.getString('auth_token');

    if (followedByUuid == null || token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('User authentication token or UUID is missing.')),
      );
      return;
    }

    final newStatus =
        _isFollowing != null && _isFollowing! ? 'unfollow' : 'follow';
    int newFollowerCount = _followerCount ?? 0;

    if (_isFollowing != null && _isFollowing!) {
      newFollowerCount = 0;
    } else {
      newFollowerCount = 1;
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/updateFollowStatus/${widget.uuid}/$followedByUuid'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': newStatus, 'follower': newFollowerCount}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _isFollowing = !_isFollowing!;
          _followerCount = newFollowerCount;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Follow status updated successfully.')),
        );
      } else {
        final error = json.decode(response.body);
        print('Failed to update follow status: ${error['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update follow status.')),
        );
      }
    } catch (e) {
      print('Error toggling follow status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while updating follow status.')),
      );
    }
  }

  Future<void> getTotalLikes(String postUuid) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('User authentication token is missing.');
    }

    final Uri url = Uri.parse('$baseUrl/sum-likes/$postUuid');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          _totalLikesCount = jsonResponse['totalLikes'];
        });
      } else {
        final jsonResponse = json.decode(response.body);
        final message =
            jsonResponse['message'] ?? 'Failed to fetch total likes';
        throw Exception(
            'Error fetching total likes: ${response.statusCode} - $message');
      }
    } catch (e) {
      throw Exception('Error fetching total likes: $e');
    }
  }

  Future<void> postFollowStatus(BuildContext context, String userUUID) async {
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

    final Uri url = Uri.parse('$baseUrl/addfollower');

    // Including 'follower' and 'following' with default values as per API requirements
    final Map<String, dynamic> body = {
      'account_uuid': userUUID,
      'followed_by_uuid': uuid,
      'status': 'unfollow', // Adjust status dynamically if needed
      'follower': 0,
      'following': 0,
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
        print(
            jsonResponse['message'] ?? 'Follower status created successfully.');
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body);
        print(
            'Validation error: ${jsonResponse['message'] ?? 'Invalid request data'}');
      } else if (response.statusCode == 500) {
        print('Internal server error');
      } else {
        final jsonResponse = json.decode(response.body);
        final message =
            jsonResponse['message'] ?? 'Failed to create follower status';
        print(
            'Error creating follower status: ${response.statusCode} - $message');
      }
    } catch (e) {
      print('Error creating follower status: $e');
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

  String getTimeDifference(String postDate, String postTime) {
    final DateFormat dateTimeFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

    DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    DateTime postDateParsed = dateFormat.parse(postDate);

    String cleanedPostTime = postTime.replaceAll(RegExp(r'[TZ]'), '');

    String combinedDateTime =
        '${dateFormat.format(postDateParsed)}T$cleanedPostTime';

    DateTime postDateTime = dateTimeFormat.parse(combinedDateTime);

    final DateTime now = DateTime.now();

    final Duration difference = now.difference(postDateTime);

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
    ThemeData theme = Theme.of(context);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: postData.length,
      itemBuilder: (context, index) {
        final post = postData[index];
        bool isLoading = profileData.isEmpty || postData.isEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: profileData[widget.uuid] != null
                    ? NetworkImage(
                        'http://192.168.1.3:8080/${profileData[widget.uuid]['imageurl']}',
                      )
                    : null,
                child: profileData[widget.uuid] == null
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoading
                      ? Shimmer(
                          duration: const Duration(seconds: 2),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.015,
                            width: MediaQuery.of(context).size.width * 0.15,
                            color: Colors.grey,
                          ),
                        )
                      : Text(
                          profileData[widget.uuid]?['username'] ?? 'Loading...',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                  isLoading
                      ? Shimmer(
                          duration: const Duration(seconds: 2),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.015,
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
              trailing: TextButton(
                onPressed: () {
                  if (_isFollowing != null) {
                    toggleFollowStatus(context);
                    refreshScreen();
                  } else {
                    // Optionally handle the null state (e.g., show a message)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Follow status is unavailable.')),
                    );
                  }
                },
                child: Text(
                  _isFollowing != null
                      ? (_isFollowing! ? 'Unfollow' : 'Follow')
                      : 'Loading...',
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 140, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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
                              'http://192.168.1.3:8080/${post['post_url']}',
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
                            icon: Icon(
                              _isLiked!
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isLiked!
                                  ? theme.colorScheme.primary
                                  : Colors.black,
                            ),
                            onPressed: toggleLikeStatus,
                          ),
                          Text(
                            '$_totalLikesCount',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.height * 0.014,
                                color: Colors.grey),
                          )
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.comment),
                        onPressed: () {
                          showCommentsBottomSheet(context);
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

  Future<void> showCommentsBottomSheet(BuildContext context) async {
    if (ModalRoute.of(context)?.isCurrent == true) {
      return await showModalBottomSheet(
        context: context,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        enableDrag: true,
        isScrollControlled: true,
        builder: (_) => CommentsBottomSheet(postUuid: widget.postUuid),
      );
    }
  }
}
