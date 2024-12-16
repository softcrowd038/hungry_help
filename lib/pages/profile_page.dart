import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quick_social/common/common.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/models/models.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    super.key,
    required this.user,
    this.isNavigatorPushed = false,
  })  : story = UserStory.dummyUserStories.firstWhere((e) => e.owner == user),
        posts = Post.dummyPosts.where((e) => e.owner == user).toList();

  static MaterialPageRoute route(User user) {
    return MaterialPageRoute(
      builder: (_) => ProfilePage(user: user, isNavigatorPushed: true),
    );
  }

  final bool isNavigatorPushed;

  final UserStory story;
  final User user;
  final List<Post> posts;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> profileData = {};

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    await getUsers();
  }

  Future<void> getUsers() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final authToken = sharedPreferences.getString('auth_token');
    final uuid = sharedPreferences.getString('user_uuid');

    final url = Uri.parse('$baseUrl/profile/$uuid');

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
            profileData = profile;
          });
        }
      } else {
        _handleError(response);
      }
    } catch (e) {
      print('Error fetching user data: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _appBar(context),
      body: ResponsivePadding(
        child: ListView(
          padding: const EdgeInsets.only(top: 0),
          shrinkWrap: true,
          children: [
            _bannerAndProfilePicture(context),
            _userBio(context),
            UserPostsTabView(uuid: profileData['uuid'] ?? ''),
          ],
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      forceMaterialTransparency: true,
      automaticallyImplyLeading: false,
      flexibleSpace: ResponsivePadding(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.isNavigatorPushed
                    ? IconButton.filledTonal(
                        onPressed: () => context.pop(),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              theme.colorScheme.primary.withAlpha(75),
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                        ),
                      )
                    : const SizedBox(),
                IconButton.filledTonal(
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary.withAlpha(75),
                  ),
                  icon: Icon(
                    widget.user.isMe ? Icons.edit : Icons.more_vert,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bannerAndProfilePicture(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final imageUrl = profileData['imageurl'];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints.expand(height: 200),
              child: Image.network(
                widget.user.bannerImage,
                fit: BoxFit.fitWidth,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.user.followersCount.toString(),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Followers'),
                    ],
                  ),
                  const SizedBox(width: 48),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.user.followingCount.toString(),
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Following'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.020,
          width: MediaQuery.of(context).size.height * 0.100,
          height: MediaQuery.of(context).size.height * 0.100,
          child: FittedBox(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.120,
              width: MediaQuery.of(context).size.height * 0.120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundImage: imageUrl != null
                    ? NetworkImage('http://192.168.1.3:8080/$imageUrl')
                    : const AssetImage('assets/placeholder_avatar.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _userBio(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.height * 0.016,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${profileData['firstname'] ?? ''} ${profileData['lastname'] ?? ''}',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('@${profileData['username'] ?? ''}',
              style: textTheme.bodyMedium),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.004,
          ),
        ],
      ),
    );
  }

  Widget _profileButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.024),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilledButton(
            onPressed: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.height * 0.024,
                vertical: MediaQuery.of(context).size.height * 0.010,
              ),
              child: const Text('Follow'),
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.height * 0.024,
                vertical: MediaQuery.of(context).size.height * 0.010,
              ),
              child: const Text('Message'),
            ),
          ),
        ],
      ),
    );
  }
}
