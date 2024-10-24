// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quick_social/data/app_data.dart';
import 'package:quick_social/pages/add_meal_page.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/pages/informer_persons_count.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/pages/notifications_page.dart';
import 'package:quick_social/widgets/layout/app_bar.dart';
import 'package:quick_social/widgets/layout/needy_people_box.dart';
import 'package:quick_social/widgets/layout/role_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('auth_token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    AppData appData = AppData();
    ThemeData theme = Theme.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: Drawer(
        shape: const LinearBorder(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HomePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('Notifications'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.012),
                child: Text(
                  'Who you are?',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            (context),
                            MaterialPageRoute(
                                builder: (context) => const AddMealPage()));
                      },
                      child: const RoleBox(
                        height: 0.15,
                        width: 0.15,
                        icon: Icons.handshake,
                        text: 'Donor',
                        textFontSize: 0.018,
                      )),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          (context),
                          MaterialPageRoute(
                              builder: (context) =>
                                  const InformerPersonsCount()));
                    },
                    child: const RoleBox(
                      height: 0.15,
                      width: 0.15,
                      icon: Icons.info,
                      text: 'Informer',
                      textFontSize: 0.018,
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.012),
                child: Text(
                  'People near you',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: appData.addresses.length,
                  itemBuilder: (context, index) {
                    return NeedyPeopleBox(
                      text: appData.addresses[index],
                      icon: Icons.place,
                      textFontSize: 0.018,
                      height: 0.10,
                      width: 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
