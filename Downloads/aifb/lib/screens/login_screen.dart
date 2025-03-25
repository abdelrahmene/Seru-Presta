import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/facebook_service.dart';

class LoginScreen extends StatelessWidget {
  final FacebookService _facebookService = Get.find();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Connexion avec Facebook',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Bouton de connexion Facebook
            ElevatedButton(
              onPressed:
                  _facebookService.isLoggedIn ? null : _facebookService.login,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.facebook),
                  SizedBox(width: 10),
                  Text('Se connecter'),
                ],
              ),
            ),
            // Bouton de profil avec animation
            Obx(() {
              if (!_facebookService.isLoggedIn) {
                return SizedBox.shrink();
              }
              return AnimatedOpacity(
                duration: Duration(milliseconds: 300),
                opacity: _facebookService.isLoggedIn ? 1.0 : 0.0,
                child: ElevatedButton(
                  onPressed: () => Get.toNamed('/profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 10),
                      Text('Mon Profil'),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
