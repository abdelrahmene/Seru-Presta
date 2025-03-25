import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/login_screen.dart';
import 'screens/profil_screen.dart';

import 'widgets/facebook_page.dart';
import 'services/facebook_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() async => FacebookService());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AIFB',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => LoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/profile',
          page: () => ProfilScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/pages',
          page: () => PagesListScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
