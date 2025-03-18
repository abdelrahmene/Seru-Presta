import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'product_detail.dart';
import '../services/cart_service.dart';
import '../services/firestore.dart';

class Shop extends StatefulWidget {
  final String selectedSubmenu;
  final Function(String) onSubmenuSelected;

  const Shop({
    Key? key,
    required this.selectedSubmenu,
    required this.onSubmenuSelected,
  }) : super(key: key);

  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  List<Map<String, dynamic>> produits = [];
  List<Map<String, dynamic>> filteredProduits = [];
  final CartService _cartService = CartService();
  Map<String, bool> _addingToCart = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedProduits = prefs.getString('produits');

      if (cachedProduits != null) {
        List<dynamic> decoded = json.decode(cachedProduits);
        produits = decoded.cast<Map<String, dynamic>>();
        _filterProduits();
      }

      await fetchAndCacheData();

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
    filteredProduits = List.from(produits);
    if (widget.selectedSubmenu.isNotEmpty) {
      filteredProduits = filteredProduits
          .where((produit) => produit['subcategory'] == widget.selectedSubmenu)
          .toList();
    }
    setState(() {});
  }

  @override
  void didUpdateWidget(covariant Shop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSubmenu != widget.selectedSubmenu) {
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
            const Text(
              'Aucun produit dans cette catégorie',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

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
        itemBuilder: (context, index) {
          final produit = filteredProduits[index];
          final isAddingToCart = _addingToCart[produit['id']] ?? false;

          return Card(
            color: Colors.black.withOpacity(0.7),
            child: InkWell(
              onTap: () {
                Get.to(() => ProductDetailPage(
                      produit: produit,
                      product: {},
                    ));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: produit['imageUrl'] ?? '',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            color: Colors.black.withOpacity(0.7),
                            child: Text(
                              produit['name'] ?? '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${produit['price']} €',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: isAddingToCart
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.blue,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.add_shopping_cart,
                                    color: Colors.blue,
                                  ),
                            onPressed: isAddingToCart
                                ? null
                                : () => _addToCart(produit),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 200.ms, delay: (50 * index).ms);
        },
      ),
    );
  }
}
