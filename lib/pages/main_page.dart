// ignore_for_file: use_build_context_synchronously, avoid_print
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quick_social/pages/add_meal_page.dart';
import 'package:quick_social/pages/donation_details.dart';
import 'package:quick_social/pages/home_page.dart';
import 'package:quick_social/pages/informer_capture_image.dart';
import 'package:quick_social/pages/login_page.dart';
import 'package:quick_social/services/closest_informer_service.dart';
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
  List<dynamic> data = [];
  List<dynamic> informerData = [];
  final ClosestInformerService _service = ClosestInformerService();

  @override
  void initState() {
    super.initState();
    fetchInformerData();
    postData();
    fetchData();
  }

  Future<void> postData() async {
    try {
      await _service.postClosestLocationData();
    } catch (e) {
      throw Exception('Error, $e');
    }
  }

  Future<void> fetchData() async {
    try {
      final closestData = await _service.getClosestLocation();
      setState(() {
        data = closestData;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchInformerData() async {
    try {
      final informerDataAll = await _service.getAllInformers();
      setState(() {
        informerData = informerDataAll;
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
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
                color: Colors.orange,
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
              leading: const Icon(FontAwesomeIcons.donate),
              title: const Text('Your Activity'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DonationDetails()));
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
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.height * 0.020),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enter Donation deatils first to get location of people near you.',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.018,
                        fontWeight: FontWeight.w100,
                        color: Colors.red),
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
                                  const InformerCaptureImage()));
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
                child: data.isNotEmpty
                    ? ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return NeedyPeopleBox(
                            text: item['location'] ?? 'Location not available',
                            icon: Icons.place,
                            textFontSize: 0.018,
                            height: 0.10,
                            width: 1,
                            informerUUID: item['closest_uuid'] ??
                                'Informer UUID is not available',
                            distance:
                                item['distance'] ?? 'no distance available',
                            imageUrl: item['imageurl'] ?? 'no url found',
                          );
                        },
                      )
                    : const Center(
                        child: Text(
                          'No nearby locations found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
