import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/facebook_service.dart';
import '../widgets/facebook_profile.dart';

class ProfilScreen extends GetView<FacebookService> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond avec dégradé
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade800,
                  Colors.blue.shade700,
                ],
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                // Header avec bouton retour
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Spacer(),
                      Text(
                        'Profil',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                ),

                // Contenu du profil
                Expanded(
                  child: Obx(() {
                    if (!controller.isLoggedIn) {
                      return Center(
                        child: ElevatedButton(
                          onPressed: controller.login,
                          child: Text('Se connecter avec Facebook'),
                        ),
                      );
                    }

                    final user = controller.user;
                    if (user == null) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return FacebookProfileWidget();
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
