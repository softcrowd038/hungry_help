import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/app.dart';
import 'package:quick_social/provider/donor_data_provider.dart';
import 'package:quick_social/provider/informer_data_provider.dart';
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
        ],
        child: const MyApp(),
      ),
    );
