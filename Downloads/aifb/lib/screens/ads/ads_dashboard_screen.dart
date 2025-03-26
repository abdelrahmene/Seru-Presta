import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/facebook_ads_services.dart';
import '../../services/facebook_service.dart';

class AdsDashboardScreen extends StatelessWidget {
  const AdsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adsService = Get.find<FacebookAdsService>();
    final facebookService = Get.find<FacebookService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionnaire de Publicités'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          if (adsService.selectedAdAccountId.isNotEmpty) {
            await Future.wait([
              adsService.fetchAds(
                adsService.selectedAdAccountId,
                facebookService.accessToken,
              ),
              adsService.fetchTotalAdsCount(
                adsService.selectedAdAccountId,
                facebookService.accessToken,
              ),
              adsService.fetchActiveAdsCount(
                adsService.selectedAdAccountId,
                facebookService.accessToken,
              ),
            ]);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Manager Section
                _buildSection(
                  title: 'Business Manager',
                  child: Obx(
                    () => DropdownButton<String>(
                      isExpanded: true,
                      value:
                          adsService.selectedBusinessId.isEmpty
                              ? null
                              : adsService.selectedBusinessId,
                      hint: const Text('Sélectionner un Business Manager'),
                      items:
                          adsService.businessAccounts.map((business) {
                            final id = business['id'] as String;
                            final name = business['name'] as String;
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          adsService.selectBusinessAccount(value);
                          await adsService.fetchAdAccounts(
                            value,
                            facebookService.accessToken,
                          );
                          await adsService.fetchPages(
                            value,
                            facebookService.accessToken,
                          );
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Ad Accounts Section
                _buildSection(
                  title: 'Comptes Publicitaires',
                  child: Obx(
                    () => DropdownButton<String>(
                      isExpanded: true,
                      value:
                          adsService.selectedAdAccountId.isEmpty
                              ? null
                              : adsService.selectedAdAccountId,
                      hint: const Text('Sélectionner un compte publicitaire'),
                      items:
                          adsService.adAccounts.map((account) {
                            final id = account['id'] as String;
                            final name = (account['name'] as String?) ?? id;
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          adsService.selectAdAccount(value);
                          await Future.wait([
                            adsService.fetchAds(
                              value,
                              facebookService.accessToken,
                            ),
                            adsService.fetchTotalAdsCount(
                              value,
                              facebookService.accessToken,
                            ),
                            adsService.fetchActiveAdsCount(
                              value,
                              facebookService.accessToken,
                            ),
                          ]);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Pages Section
                _buildSection(
                  title: 'Pages Facebook',
                  child: Obx(
                    () =>
                        adsService.pages.isEmpty
                            ? const Center(
                              child: Text('Aucune page disponible'),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: adsService.pages.length,
                              itemBuilder: (context, index) {
                                final page = adsService.pages[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: _buildPageImage(
                                      page['picture']?['data']?['url']
                                          as String?,
                                    ),
                                    title: Text(
                                      page['name'] as String,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('ID: ${page['id']}'),
                                        Text(
                                          'Catégorie: ${page['category'] ?? 'Non spécifiée'}',
                                        ),
                                        Text(
                                          'Catégorie ID: ${page['category_id'] ?? 'Non spécifié'}',
                                        ),
                                      ],
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Colors.green,
                                          size: 12,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Active',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),

                const SizedBox(height: 16),

                // Stats Grid
                Obx(
                  () => GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        title: 'Total Publicités',
                        value: '${adsService.totalAdsCount}',
                        icon: Icons.ads_click,
                        color: Theme.of(context).primaryColor,
                      ),
                      _buildStatCard(
                        title: 'Publicités Actives',
                        value: '${adsService.activeAdsCount}',
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Ads List Section
                _buildSection(
                  title: 'Liste des Publicités',
                  child: Obx(
                    () =>
                        adsService.ads.isEmpty
                            ? const Center(
                              child: Text('Aucune publicité disponible'),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: adsService.ads.length,
                              itemBuilder: (context, index) {
                                final ad = adsService.ads[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: _buildAdImage(
                                      ad['creative']?['thumbnail_url']
                                          as String?,
                                    ),
                                    title: Text(
                                      ad['name'] as String? ?? 'Sans nom',
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Status: ${ad['status']}'),
                                        Text(
                                          'Créé le: ${DateTime.parse(ad['created_time'] as String).toString().split(' ')[0]}',
                                        ),
                                      ],
                                    ),
                                    trailing: _buildStatusIndicator(
                                      ad['status'] as String,
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageImage(String? imageUrl) {
    if (imageUrl == null) {
      return _buildImagePlaceholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildAdImage(String? imageUrl) {
    if (imageUrl == null) {
      return _buildImagePlaceholder();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }

  Widget _buildStatusIndicator(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'paused':
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case 'deleted':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Icon(icon, color: color);
  }
}
