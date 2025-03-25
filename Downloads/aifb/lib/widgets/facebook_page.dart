import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/facebook_service.dart';

class PagesListScreen extends StatelessWidget {
  final FacebookService controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [_buildAppBar(), _buildPagesList()],
      ),
      floatingActionButton: _buildLogoutButton(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Obx(() {
          if (controller.user == null) {
            return const Text(
              'MES PAGES',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            );
          }
          return Text(
            'MES PAGES',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          );
        }),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blueGrey.shade900.withOpacity(0.8),
                Colors.black.withOpacity(0.9),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return FloatingActionButton.extended(
      onPressed: () => controller.logout(),
      label: const Text(
        'DÉCONNEXION',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
      icon: const Icon(Icons.logout, size: 20),
      backgroundColor: Colors.redAccent[700],
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.5, end: 0);
  }

  Widget _buildPagesList() {
    return Obx(() {
      if (controller.pages.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child:
                Text(
                  'AUCUNE PAGE TROUVÉE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().fadeIn(),
          ),
        );
      }
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildPageItem(controller.pages[index])
              .animate()
              .fadeIn(delay: (100 * index).ms)
              .slideX(begin: 0.3, end: 0),
          childCount: controller.pages.length,
        ),
      );
    });
  }

  Widget _buildPageItem(Map<String, dynamic> page) {
    final pageName = page['name'] ?? 'Sans nom';
    final description = page['about'] ?? page['description'];
    final category = page['category'];
    final website = page['website'];
    final phone = page['phone'];
    final location = page['location'];
    final emails = page['emails'] is List ? page['emails'].first : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          splashColor: Colors.blueGrey.withOpacity(0.3),
          highlightColor: Colors.blueGrey.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and category
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pageName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (category != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Colors.blueAccent[100],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Description
                if (description != null)
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 16),

                // Info grid
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    if (website != null)
                      _buildInfoChip(Icons.public, website, isLink: true),

                    if (emails != null) _buildInfoChip(Icons.email, emails),

                    if (phone != null) _buildInfoChip(Icons.phone, phone),

                    if (location != null)
                      _buildInfoChip(
                        Icons.location_on,
                        location['city'] ??
                            location['street'] ??
                            'Emplacement inconnu',
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, {bool isLink = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[800]?.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 150),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                decoration: isLink ? TextDecoration.underline : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
