import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/facebook_service.dart';

class DashboardPage extends StatelessWidget {
  final FacebookService facebookService = Get.find<FacebookService>();

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard Facebook")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(),
            _buildPagesInfo(),
            Expanded(child: _buildPostsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Obx(() {
      final user = facebookService.user;
      return user != null
          ? ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user['picture']['data']['url']),
            ),
            title: Text(user['name']),
            subtitle: Text(user['email'] ?? "Pas d'email"),
          )
          : const Text("Utilisateur non connecté");
    });
  }

  Widget _buildPagesInfo() {
    return Obx(() {
      final pages = facebookService.pages;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pages gérées :",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...pages.map(
            (page) => ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(page['picture']['data']['url']),
              ),
              title: Text(page['name']),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle),
                color:
                    facebookService.selectedPage.value?['id'] == page['id']
                        ? Colors.green
                        : Colors.grey,
                onPressed: () => facebookService.selectPage(page),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPostsList() {
    return Obx(() {
      final selectedPage = facebookService.selectedPage.value;

      if (selectedPage == null) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 48),
              SizedBox(height: 16),
              Text(
                "Veuillez sélectionner une page",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
        );
      }

      return FutureBuilder(
        future: facebookService.fetchPagePosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else {
            final posts = snapshot.data as List<Map<String, dynamic>>;
            return posts.isEmpty
                ? const Center(child: Text("Aucun post trouvé"))
                : ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post['message'] ?? "Pas de message",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              post['created_time'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            if (post['attachments'] != null) ...[
                              const SizedBox(height: 8),
                              ...List.generate(
                                (post['attachments']?['data'] as List).length,
                                (i) {
                                  final attachment =
                                      (post['attachments']?['data'] as List)[i];
                                  if (attachment['type'] == 'photo' &&
                                      attachment['media'] != null) {
                                    return Image.network(
                                      attachment['media']['image']['src'],
                                      height: 200,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.red[200],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post['likes']?['summary']?['total_count'] ?? 0}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.comment,
                                  color: Colors.grey[400],
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post['comments']?['summary']?['total_count'] ?? 0}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
          }
        },
      );
    });
  }
}
