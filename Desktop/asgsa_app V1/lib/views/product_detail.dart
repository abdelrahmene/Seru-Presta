import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:asgsa_app/services/cart_service.dart';
import 'package:get/get.dart';

class ProductDetailPage extends StatelessWidget {
  final Map<String, dynamic> produit;
  final CartService _cartService = Get.find<CartService>();

  ProductDetailPage(
      {super.key,
      required this.produit,
      required Map<String, dynamic> product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌊 Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/animations/shipImage.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ).animate().fade(duration: 800.ms),
          ),

          // 📌 Product Details
          SafeArea(
            child: Column(
              children: [
                Hero(
                  tag: produit["id"],
                  child: CachedNetworkImage(
                    imageUrl: produit["image"] ?? "",
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(color: Colors.blue)),
                    errorWidget: (context, url, error) => const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                        size: 100),
                  ).animate().fade().slideY(),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 30),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          produit["nom"] ?? "Produit inconnu",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ).animate().fade().slideX(),

                        const SizedBox(height: 10),

                        Text(
                          "${produit["prix"]} €",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ).animate().fade().slideX(),

                        const SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            produit["description"]?.isNotEmpty == true
                                ? produit["description"]
                                : "Aucune description disponible",
                            style: const TextStyle(
                                fontSize: 16, color: Colors.white70),
                            textAlign: TextAlign.justify,
                          ),
                        ).animate().fade().slideY(),

                        const Spacer(),

                        // 🔥 Add to Cart Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              await _cartService.addToCart(produit);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Produit ajouté au panier !"),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 10,
                            ),
                            child: const Text(
                              "Ajouter au panier",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ).animate().fade().scale(),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
