import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/app.dart';
import 'package:quick_social/provider/profile_data_provider.dart';

void main() => runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProfileProvider(),
        ),
      ],
      child:const MyApp(),
    ),
  );
