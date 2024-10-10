import 'package:flutter/material.dart';
import 'package:quick_social/common/common.dart';
import 'package:quick_social/models/models.dart';
import 'package:quick_social/pages/pages.dart';
import 'package:quick_social/widgets/widgets.dart';

class ProfilePage extends StatelessWidget {
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
            UserPostsTabView(posts: posts),
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
                isNavigatorPushed
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
                    user.isMe ? Icons.settings : Icons.more_vert,
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
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Column(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints.expand(height: 200),
              child: Image.network(
                user.bannerImage,
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
                        user.followersCount.toString(),
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
                        user.followingCount.toString(),
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
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: UserStoryAvatar(
                userStory: story,
                onTap: () {},
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
            user.fullname,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('@${user.username}', style: textTheme.bodyMedium),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.004,
          ),
          Text(
            user.bio,
            style: textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          user.isMe
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.024,
                )
              : _profileButtons(context),
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
