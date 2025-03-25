import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/facebook_service.dart';

class FacebookProfileWidget extends StatelessWidget {
  final FacebookService _facebookService = Get.find();

  FacebookProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!_facebookService.isLoggedIn) {
        return Center(
          child: ElevatedButton(
            onPressed: _facebookService.login,
            child: Text('Se connecter avec Facebook'),
          ),
        );
      }

      final user = _facebookService.user;
      if (user == null) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(user['picture']['data']['url']),
          ),
          SizedBox(height: 20),
          Text(
            user['name'],
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('ID: ${user['id']}', style: TextStyle(fontSize: 16)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              print('FacebookProfileWidget: Navigate to pages screen');
              Get.toNamed('/pages');
            },
            child: Text('Mes Pages Facebook'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _facebookService.logout,
            child: Text('Déconnexion'),
          ),
        ],
      );
    });
  }
}
