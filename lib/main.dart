import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/app.dart';
import 'package:quick_social/provider/closest_informer_provider.dart';
import 'package:quick_social/provider/donor_data_provider.dart';
import 'package:quick_social/provider/informer_data_provider.dart';
import 'package:quick_social/provider/live_location_provider.dart';
import 'package:quick_social/provider/post_provider.dart';
import 'package:quick_social/provider/profile_data_provider.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => UserProfileProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => DonorDataProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => InformerDataProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ClosestInformerProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => LocationProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => PostProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    );
