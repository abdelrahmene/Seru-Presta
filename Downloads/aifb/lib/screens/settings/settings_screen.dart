import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/facebook_service.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FacebookService facebookService = Get.find<FacebookService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Compte'),
          Obx(() {
            final user = facebookService.user;
            if (user != null) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    user['picture']['data']['url'],
                  ),
                ),
                title: Text(user['name']),
                subtitle: const Text('Compte Facebook connecté'),
                trailing: TextButton(
                  onPressed: () async {
                    try {
                      await facebookService.logout();
                      Get.offAllNamed('/');
                    } catch (e) {
                      Get.snackbar(
                        'Erreur',
                        'Impossible de se déconnecter',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: const Text('Déconnexion'),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          const _SectionHeader(title: 'Automatisation'),
          SwitchListTile(
            title: const Text('Activer les réponses automatiques'),
            subtitle: const Text('Pour les messages et commentaires'),
            value: true, // TODO: Lier à un état réel
            onChanged: (value) {
              // TODO: Mettre à jour l'état
            },
          ),
          SwitchListTile(
            title: const Text('Mode silencieux'),
            subtitle: const Text('Désactiver les notifications'),
            value: false, // TODO: Lier à un état réel
            onChanged: (value) {
              // TODO: Mettre à jour l'état
            },
          ),

          const _SectionHeader(title: 'Notifications'),
          ListTile(
            title: const Text('Fréquence des notifications'),
            subtitle: const Text('Immédiate'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Ouvrir les paramètres de fréquence
            },
          ),
          SwitchListTile(
            title: const Text('Notifications par email'),
            subtitle: const Text('Rapports quotidiens'),
            value: true, // TODO: Lier à un état réel
            onChanged: (value) {
              // TODO: Mettre à jour l'état
            },
          ),

          const _SectionHeader(title: 'Apparence'),
          ListTile(
            title: const Text('Thème'),
            subtitle: const Text('Système'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Ouvrir les paramètres de thème
            },
          ),

          const _SectionHeader(title: 'À propos'),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            title: const Text('Politique de confidentialité'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Ouvrir la politique de confidentialité
            },
          ),
          ListTile(
            title: const Text('Conditions d\'utilisation'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Ouvrir les conditions d'utilisation
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }
}
