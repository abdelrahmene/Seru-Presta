import 'dart:convert';

import 'package:asgsa_app/views/about_us_page.dart';
import 'package:asgsa_app/views/product_detail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cart_service.dart';
import '../services/firestore.dart';

class HomeContent extends StatefulWidget {
  final String selectedCategory;
  final String selectedSubmenu;
  final Function(String) onCategorySelected;
  final Function(String) onSubmenuSelected;

  const HomeContent({
    Key? key,
    required this.selectedCategory,
    required this.selectedSubmenu,
    required this.onCategorySelected,
    required this.onSubmenuSelected,
  }) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> produits = [];
  List<Map<String, dynamic>> filteredProduits = [];
  final CartService _cartService = CartService();
  Map<String, bool> _addingToCart = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fetchAndLoadProduits();
  }

  Future<void> _fetchAndLoadProduits() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Tente d'abord de charger depuis le cache
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedProduits = prefs.getString('produits');

      if (cachedProduits != null) {
        List<dynamic> decoded = json.decode(cachedProduits);
        produits = decoded.cast<Map<String, dynamic>>();
        _filterProduits();
      }

      // Rafraîchit les données depuis Firestore
      await fetchAndCacheData();

      // Recharge les données mises à jour
      cachedProduits = prefs.getString('produits');
      if (cachedProduits != null) {
        List<dynamic> decoded = json.decode(cachedProduits);
        produits = decoded.cast<Map<String, dynamic>>();
        _filterProduits();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Erreur lors du chargement des produits: $e');
      }
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage =
            'Erreur de chargement des produits. Veuillez réessayer.';
      });
    }
  }

  void _filterProduits() {
    if (widget.selectedCategory.isEmpty || widget.selectedCategory == "Shop") {
      filteredProduits = List.from(produits);
    } else {
      filteredProduits = produits
          .where((produit) => produit['categoryId'] == widget.selectedCategory)
          .toList();
    }
    if (widget.selectedSubmenu.isNotEmpty) {
      filteredProduits = filteredProduits
          .where((produit) => produit['subcategory'] == widget.selectedSubmenu)
          .toList();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant HomeContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCategory != widget.selectedCategory ||
        oldWidget.selectedSubmenu != widget.selectedSubmenu) {
      _filterProduits();
    }
  }

  Future<void> _addToCart(Map<String, dynamic> produit) async {
    setState(() => _addingToCart[produit['id']] = true);
    try {
      await _cartService.addToCart(produit);
      Get.snackbar(
        'Succès',
        'Produit ajouté au panier',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter le produit au panier',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    setState(() => _addingToCart[produit['id']] = false);
  }

  Future<void> _onRefresh() async {
    await _fetchAndLoadProduits();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (filteredProduits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                color: Colors.blue, size: 48),
            const SizedBox(height: 16),
            Text(
              widget.selectedCategory == "Shop"
                  ? 'Aucun produit disponible'
                  : 'Aucun produit dans cette catégorie',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    switch (widget.selectedCategory) {
      case "About Us":
        return const AboutUsPage();
      case "Crew Change":
        return const Center(
          child: Text(
            'Crew Change Service',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case "Spare Parts":
        return const Center(
          child: Text(
            'Spare Parts Service',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        );
      case "Shop":
      default:
        // Utilisation d'une ValueKey pour forcer la reconstruction lors des changements
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: Colors.blue,
          backgroundColor: Colors.black,
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: filteredProduits.length,
            itemBuilder: (context, index) =>
                _buildProductCard(filteredProduits[index], index),
          ).animate().fadeIn(),
        ).animate().slideY(
              begin: 0.3,
              end: 0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutQuad,
            );
    }
  }

  Widget _buildProductCard(Map<String, dynamic> produit, int index) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.black87,
      child: InkWell(
        onTap: () => Get.to(() => ProductDetailPage(
              produit: produit,
              product: {},
            )),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.withOpacity(0.3),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: CachedNetworkImage(
                    imageUrl: produit['image'] ?? '',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[900],
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[900],
                      child: const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          produit['nom'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${produit['prix']} €',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: _addingToCart[produit['id']] == true
                              ? null
                              : () => _addToCart(produit),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _addingToCart[produit['id']] == true
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Ajouter',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().slideY(
          begin: 0.3,
          end: 0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuad,
        );
  }
}
