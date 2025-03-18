import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../widgets/background_container.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed('/LoginPage');
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de se déconnecter',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return BackgroundContainer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.blue.shade300,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'Utilisateur',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileButton(
              icon: Icons.shopping_bag,
              title: 'Mes commandes',
              onTap: () {
                Get.toNamed('/orders');
              },
            ),
            const SizedBox(height: 16),
            _buildProfileButton(
              icon: Icons.settings,
              title: 'Paramètres',
              onTap: () {
                Get.toNamed('/settings');
              },
            ),
            const SizedBox(height: 16),
            _buildProfileButton(
              icon: Icons.help,
              title: 'Aide',
              onTap: () {
                Get.toNamed('/help');
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('Déconnexion'),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.black87,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.blue,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
