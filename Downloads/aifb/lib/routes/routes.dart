import 'package:aifb/screens/auth/login_screen.dart';
import 'package:get/get.dart';
import '../screens/dashboard/dashboard_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static final List<GetPage> routes = [
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: dashboard, page: () => const DashboardScreen()),
  ];
}
