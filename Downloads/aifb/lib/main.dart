import 'package:aifb/screens/auth/login_screen.dart';
import 'package:aifb/screens/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/routes.dart';
import 'services/facebook_service.dart';
import 'services/facebook_ads_services.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FB Auto-Response',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.login,
      getPages: AppRoutes.routes,
      initialBinding: BindingsBuilder(() {
        Get.put(FacebookService());
        Get.put(FacebookAdsService());
      }),
      home: FutureBuilder(
        future: () async {
          final facebookService = Get.find<FacebookService>();
          await facebookService.checkAndRestoreSession();
          return facebookService.isLoggedIn;
        }(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData && snapshot.data == true) {
            return const DashboardScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
