// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/common/common.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/models/models.dart';
import 'package:quick_social/models/user_model.dart';
import 'package:quick_social/pages/update_profile.dart';
import 'package:quick_social/provider/user_provider.dart';
import 'package:quick_social/services/followers_service.dart';
import 'package:quick_social/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    super.key,
    required this.user,
    this.isNavigatorPushed = false,
  }) : story = UserStory.dummyUserStories.firstWhere((e) => e.owner == user);

  static MaterialPageRoute route(User user) {
    return MaterialPageRoute(
      builder: (_) => ProfilePage(user: user, isNavigatorPushed: true),
    );
  }

  final bool isNavigatorPushed;
  final UserStory story;
  final User user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> profileData = {};
  int? followers;
  int? following;
  FollowersService followersService = FollowersService();
  UserAccount? profile;
  bool isLoading = true;

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
      await userProvider.fetchUserProfile(uuid);
      final fetchedProfile = userProvider.getUser(uuid);

      if (!mounted) return;

      setState(() {
        profile = fetchedProfile;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

    await getStats();
    await getFollowingStats();
  }

  Future<void> getStats() async {
    try {
      final stats = await followersService.getFollowersCount();

      if (!mounted) return;

      setState(() {
        followers = stats['total_followers'];
      });
    } catch (e) {
      print('Error fetching followers stats: $e');
      if (mounted) {
        setState(() {
          followers = 0;
        });
      }
    }
  }

  Future<void> getFollowingStats() async {
    try {
      final stats = await followersService.getFollowingCount();

      if (!mounted) return;

      setState(() {
        following = stats['total_following'];
      });
    } catch (e) {
      print('Error fetching following stats: $e');
      if (mounted) {
        setState(() {
          following = 0;
        });
      }
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
            if (profile != null)
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
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileUpdatePage()));
                  },
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

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profile == null) {
      return const Center(child: Text('Profile not available'));
    }

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
                      followers != null
                          ? Text(
                              '$followers',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Shimmer(
                              child: Container(
                                width: 30,
                                height: 20,
                                color: Colors.grey,
                              ),
                            ),
                      const Text('Followers'),
                    ],
                  ),
                  const SizedBox(width: 48),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      following != null
                          ? Text(
                              '$following',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Shimmer(
                              child: Container(
                                width: 30,
                                height: 20,
                                color: Colors.grey,
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
                backgroundImage: profile!.userProfile.imageurl != null
                    ? NetworkImage(
                        '$imageBaseUrl${profile!.userProfile.imageurl}')
                    : const AssetImage('assets/images/placeholder_avatar.png'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _userBio(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (profile == null) {
      return const Center(child: Text('User bio not available'));
    }

    final userProfile = profile!.userProfile;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.height * 0.016,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${userProfile.firstname ?? 'First Name'} ${userProfile.lastname ?? 'Last Name'}',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '@${userProfile.username ?? 'Username'}',
            style: textTheme.bodyMedium,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.004,
          ),
        ],
      ),
    );
  }
}
