import 'package:flutter/material.dart';
import 'package:quick_social/common/common.dart';
import 'package:quick_social/models/models.dart';
import 'package:quick_social/pages/main_page.dart';
import 'package:quick_social/pages/pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const HomePage());
  }

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _pageIndex = 0;
  late PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pageView = _buildPageView();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: context.responsive(
        sm: pageView,
        md: Row(
          children: [
            _navigationRail(context),
            const VerticalDivider(width: 1, thickness: 1),
            Flexible(child: pageView),
          ],
        ),
      ),
      bottomNavigationBar: context.isMobile ? _navigationBar(context) : null,
    );
  }

  void _pageChanged(int value) {
    if (_pageIndex == value && _pageController.hasClients) return;
    setState(() => _pageIndex = value);
    _pageController.jumpToPage(value);
  }

  Widget _buildPageView() {
    _pageController = PageController(initialPage: _pageIndex);

    return PageView(
      controller: _pageController,
      onPageChanged: _pageChanged,
      children: [
        const MainPage(),
        const FeedPage(),
        ProfilePage(user: User.dummyUsers[0]),
      ],
    );
  }

  NavigationRail _navigationRail(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return NavigationRail(
      selectedIndex: _pageIndex,
      onDestinationSelected: _pageChanged,
      extended: context.isDesktop,
      labelType: context.isDesktop
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      selectedLabelTextStyle: textTheme.bodyMedium?.copyWith(
        color: Colors.orange,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: textTheme.bodyMedium,
      destinations: [
        NavigationRailDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(
            Icons.home,
            color: Colors.orange,
          ),
          label: const Text('Home'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.explore),
          selectedIcon: Icon(
            Icons.explore,
            color: Colors.orange,
          ),
          label: const Text('Explore'),
        ),
        NavigationRailDestination(
          icon: const Icon(Icons.person_outlined),
          selectedIcon: Icon(
            Icons.person,
            color: Colors.orange,
          ),
          label: const Text('Profile'),
        ),
      ],
    );
  }

  NavigationBar _navigationBar(BuildContext context) {
    final theme = Theme.of(context);
    return NavigationBar(
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      selectedIndex: _pageIndex,
      height: MediaQuery.of(context).size.height * 0.065,
      onDestinationSelected: _pageChanged,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: Icon(
            Icons.home,
            color: Colors.orange,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: const Icon(Icons.explore),
          selectedIcon: Icon(
            Icons.explore,
            color: Colors.orange,
          ),
          label: 'Add',
        ),
        NavigationDestination(
          icon: const Icon(Icons.person_outlined),
          selectedIcon: Icon(
            Icons.person,
            color: Colors.orange,
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
