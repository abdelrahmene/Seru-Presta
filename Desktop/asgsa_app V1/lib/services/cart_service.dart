import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'invoice_service.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'quantity': quantity,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    name: json['name'],
    price: (json['price'] as num).toDouble(),
    quantity: json['quantity'],
  );
}

class CartService extends GetxController {
  final _items = <CartItem>[].obs;
  final _isCheckingOut = false.obs;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot>? _cartSubscription;

  List<CartItem> get items => _items;
  bool get isCheckingOut => _isCheckingOut.value;

  double get total => _items.fold(
    0.0,
    (sum, item) => sum + (item.price * item.quantity),
  );

  @override
  void onInit() {
    super.onInit();
    _setupCartStream();
  }

  @override
  void onClose() {
    _cartSubscription?.cancel();
    super.onClose();
  }

  void _setupCartStream() {
    final user = _auth.currentUser;
    if (user == null) return;

    _cartSubscription?.cancel();
    _cartSubscription = _firestore
      .collection('users')
      .doc(user.uid)
      .collection('cart')
      .snapshots()
      .listen(
        (snapshot) {
          final items = snapshot.docs
            .map((doc) => CartItem.fromJson(doc.data()))
            .toList();
          _items.assignAll(items);
        },
        onError: (error) {
          Get.snackbar(
            'Erreur',
            'Impossible de charger le panier: $error',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(8),
            borderRadius: 8,
          );
        },
      );
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Erreur',
          'Vous devez être connecté pour ajouter au panier',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(8),
          borderRadius: 8,
        );
        return;
      }

      // Vérifier si le produit existe déjà dans le panier
      final userCartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart');
          
      final existingItemDoc = await userCartRef.doc(product['id'].toString()).get();

      if (existingItemDoc.exists) {
        // Mettre à jour la quantité si le produit existe déjà
        final existingData = existingItemDoc.data() as Map<String, dynamic>;
        final updatedItem = CartItem(
          id: product['id'].toString(),
          name: product['nom'].toString(),
          price: double.parse(product['prix'].toString()),
          quantity: (existingData['quantity'] as int) + 1,
        );

        await userCartRef
          .doc(updatedItem.id)
          .set(updatedItem.toJson());
      } else {
        // Ajouter un nouveau produit
        final item = CartItem(
          id: product['id'].toString(),
          name: product['nom'].toString(),
          price: double.parse(product['prix'].toString()),
          quantity: 1,
        );

        await userCartRef
          .doc(item.id)
          .set(item.toJson());
      }

      Get.snackbar(
        'Succès',
        'Produit ajouté au panier',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } catch (e) {
      print('Erreur lors de l\'ajout au panier: $e'); // Pour le débogage
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter au panier: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(itemId)
        .delete();

      Get.snackbar(
        'Succès',
        'Produit retiré du panier',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de retirer le produit: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
      rethrow;
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      if (newQuantity < 1) {
        await removeItem(itemId);
        return;
      }

      final user = _auth.currentUser;
      if (user == null) return;

      final existingItemIndex = _items.indexWhere((item) => item.id == itemId);
      if (existingItemIndex == -1) return;

      final existingItem = _items[existingItemIndex];
      final updatedItem = CartItem(
        id: existingItem.id,
        name: existingItem.name,
        price: existingItem.price,
        quantity: newQuantity,
      );

      await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(itemId)
        .set(updatedItem.toJson());

    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de mettre à jour la quantité: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: 8,
      );
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      final cartRef = _firestore.collection('users').doc(user.uid).collection('cart');
      final cartItems = await cartRef.get();
      
      for (var doc in cartItems.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      _items.clear();
    } catch (e) {
      print('Erreur lors du vidage du panier: $e');
      rethrow;
    }
  }

  Future<void> checkout() async {
    try {
      _isCheckingOut.value = true;
      final user = _auth.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      if (_items.isEmpty) throw Exception('Le panier est vide');

      // Créer une nouvelle facture
      final invoiceService = Get.find<InvoiceService>();
      final newInvoiceNumber = DateTime.now().millisecondsSinceEpoch;
      
      final invoice = Invoice(
        id: 'INV-$newInvoiceNumber',
        number: newInvoiceNumber,
        date: DateTime.now(),
        total: total,
        userId: user.uid,
        items: _items.map((item) => {
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': item.quantity,
        }).toList(),
      );

      // Générer la facture
      await invoiceService.generateInvoice(invoice);

      // Vider le panier
      await clearCart();

      Get.snackbar(
        'Succès',
        'Commande validée avec succès !',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('Erreur lors du checkout: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de valider la commande: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      _isCheckingOut.value = false;
    }
  }
}