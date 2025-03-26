import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aifb/services/facebook_service.dart';
import 'package:aifb/services/facebook_ads_services.dart';
import 'package:aifb/routes/routes.dart';

class AutomationScreen extends StatelessWidget {
  const AutomationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final facebookService = Get.find<FacebookService>();
    final facebookAdsService = Get.find<FacebookAdsService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Automatisation'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await facebookAdsService.fetchPages(
                facebookAdsService.selectedBusinessId,
                facebookService.accessToken,
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (facebookAdsService.selectedBusinessId.isNotEmpty) {
            await Future.wait([
              facebookAdsService.fetchPages(
                facebookAdsService.selectedBusinessId,
                facebookService.accessToken,
              ),
              facebookAdsService.fetchAdAccounts(
                facebookAdsService.selectedBusinessId,
                facebookService.accessToken,
              ),
              facebookAdsService.fetchBusinessAccounts(
                facebookService.accessToken,
              ),
            ]);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section Configuration Automatisation
                  _buildSection(
                    title: 'Configuration Automatisation',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Réponses automatiques
                        _buildAutomationToggle(
                          title: 'Réponses automatiques',
                          description:
                              'Activer les réponses automatiques aux commentaires',
                          value: facebookService.isAutomationEnabled,
                          onChanged: (value) {
                            facebookService.setAutomationEnabled(value);
                          },
                        ),

                        const SizedBox(height: 16),

                        // Configuration des réponses
                        _buildAutomationConfig(
                          title: 'Configuration des réponses',
                          onTap: () {
                            Get.toNamed('/automation/config');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRuleDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildAutomationToggle({
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildAutomationConfig({
    required String title,
    required Function() onTap,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _showAddRuleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Nouvelle règle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Type de réponse',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'messages',
                      child: Text('Messages privés'),
                    ),
                    DropdownMenuItem(
                      value: 'comments',
                      child: Text('Commentaires'),
                    ),
                    DropdownMenuItem(
                      value: 'both',
                      child: Text('Messages & Commentaires'),
                    ),
                  ],
                  onChanged: (value) {
                    // TODO: Implémenter la logique de sélection
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Modèle IA'),
                  items: const [
                    DropdownMenuItem(
                      value: 'conversational',
                      child: Text('IA Conversationnelle'),
                    ),
                    DropdownMenuItem(
                      value: 'support',
                      child: Text('Support Client'),
                    ),
                    DropdownMenuItem(value: 'sales', child: Text('Ventes')),
                  ],
                  onChanged: (value) {
                    // TODO: Implémenter la logique de sélection
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implémenter la logique de création de règle
                  Navigator.pop(context);
                },
                child: const Text('Créer'),
              ),
            ],
          ),
    );
  }
}
