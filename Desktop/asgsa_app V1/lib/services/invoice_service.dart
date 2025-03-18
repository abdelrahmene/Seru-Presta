import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:developer' as developer;

class Invoice {
  final String id;
  final int number;
  final DateTime date;
  final double total;
  final String userId;
  final List<Map<String, dynamic>> items;

  Invoice({
    required this.id,
    required this.number,
    required this.date,
    required this.total,
    required this.userId,
    required this.items,
  });

  factory Invoice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      number: data['number'] ?? 0,
      date: (data['date'] as Timestamp).toDate(),
      total: (data['total'] as num).toDouble(),
      userId: data['userId'] as String,
      items: List<Map<String, dynamic>>.from(data['items'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'number': number,
    'date': Timestamp.fromDate(date),
    'total': total,
    'userId': userId,
    'items': items,
  };
}

class InvoiceService extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxList<Invoice> _invoices = <Invoice>[].obs;
  StreamSubscription? _invoicesSubscription;
  bool _isInitialized = false;

  List<Invoice> get invoices => _invoices;

  @override
  void onInit() {
    super.onInit();
    _setupAuthListener();
  }

  @override
  void onClose() {
    _invoicesSubscription?.cancel();
    super.onClose();
  }

  void _setupAuthListener() {
    developer.log('🔄 Configuration de l\'écouteur d\'authentification');
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        developer.log('👤 Utilisateur connecté dans l\'écouteur: ${user.uid}');
        _initializeFirestore();
        _listenToInvoices();
      } else {
        developer.log('👤 Utilisateur déconnecté dans l\'écouteur');
        _cleanupSubscriptions();
      }
    }, onError: (error) {
      developer.log('❌ Erreur dans l\'écouteur d\'authentification', error: error);
    });
  }

  void _initializeFirestore() {
    if (_isInitialized) return;
    developer.log('🔄 Initialisation de Firestore...');
    try {
      _firestore.enableNetwork();
      _isInitialized = true;
      developer.log('✅ Firestore initialisé avec succès');
    } catch (e) {
      developer.log('❌ Erreur lors de l\'initialisation de Firestore', error: e);
    }
  }

  void _cleanupSubscriptions() {
    _invoicesSubscription?.cancel();
    _invoices.clear();
    _invoices.refresh();
  }

  void _listenToInvoices() {
    _cleanupSubscriptions();

    final userId = _auth.currentUser?.uid;
    developer.log('🔍 ID Utilisateur actuel dans _listenToInvoices: $userId');

    if (userId == null) {
      developer.log('❌ Utilisateur non connecté dans _listenToInvoices');
      return;
    }

    try {
      final collectionPath = 'users/$userId/invoices';
      developer.log('📁 Chemin de la collection: $collectionPath');

      _invoicesSubscription = _firestore
          .collection('users')
          .doc(userId)
          .collection('invoices')
          .orderBy('number', descending: true)
          .snapshots()
          .listen(
        (snapshot) {
          try {
            final newInvoices = snapshot.docs.map((doc) {
              developer.log('📄 Document trouvé - ID: ${doc.id}');
              return Invoice.fromFirestore(doc);
            }).toList();

            developer.log('📄 Nombre de factures trouvées: ${newInvoices.length}');
            
            if (newInvoices.isEmpty) {
              developer.log('⚠️ Aucune facture trouvée pour l\'utilisateur $userId');
            } else {
              developer.log('✅ ${newInvoices.length} factures trouvées');
              for (var invoice in newInvoices) {
                developer.log('📝 Facture - ID: ${invoice.id}, Numéro: ${invoice.number}');
              }
            }

            _invoices.clear();
            _invoices.addAll(newInvoices);
            _invoices.refresh();
            
          } catch (e) {
            developer.log('❌ Erreur lors du traitement des factures', error: e);
          }
        },
        onError: (e) {
          developer.log('❌ Erreur lors de l\'écoute des factures', error: e);
          _showError('Erreur lors du chargement des factures');
        },
        cancelOnError: false,
      );
    } catch (e) {
      developer.log('❌ Erreur lors de l\'initialisation de l\'écoute des factures', error: e);
      _showError('Erreur lors de l\'initialisation du suivi des factures');
    }
  }

  Future<void> downloadInvoice(String invoiceId) async {
    try {
      developer.log('Téléchargement de la facture: $invoiceId');
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('Utilisateur non connecté');
      }
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('invoices')
          .doc(invoiceId)
          .get();

      if (!snapshot.exists) {
        throw Exception('Facture non trouvée');
      }
      final invoice = Invoice.fromFirestore(snapshot);
      final pdf = await _generatePdf(invoice);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/facture_${invoice.number}.pdf');
      await file.writeAsBytes(await pdf.save());

      developer.log('Facture enregistrée: ${file.path}');
      _showSuccess('Facture enregistrée: facture_${invoice.number}.pdf');
    } catch (e, stackTrace) {
      developer.log('Erreur lors du téléchargement de la facture', error: e, stackTrace: stackTrace);
      _showError('Impossible de télécharger la facture: $e');
    }
  }

  Future<pw.Document> _generatePdf(Invoice invoice) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, text: 'FACTURE'),
              pw.Text('Facture N° ${invoice.number}'),
              pw.Text('Date: ${invoice.date.day}/${invoice.date.month}/${invoice.date.year}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Article', 'Quantité', 'Prix'],
                data: invoice.items.map((item) => [item['name'], item['quantity'], item['price']]).toList(),
              ),
              pw.Divider(),
              pw.Text('Total: ${invoice.total}€', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  void _showSuccess(String message) {
    Get.snackbar('Succès', message, backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
  }

  void _showError(String message) {
    Get.snackbar('Erreur', message, backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
  }

  Future<void> generateInvoice(Invoice invoice) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        developer.log('Erreur: Utilisateur non connecté');
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('invoices')
          .doc(invoice.id)
          .set(invoice.toFirestore());

      developer.log('Facture générée avec succès: ${invoice.id}');
      Get.snackbar(
        'Succès',
        'Facture générée avec succès',
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );

      _listenToInvoices(); // Rafraîchir la liste après ajout
    } catch (e, stackTrace) {
      developer.log(
        'Erreur lors de la génération de la facture',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Erreur',
        'Impossible de générer la facture: $e',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  void refreshInvoices() {
    developer.log('🔄 Rafraîchissement forcé des factures...');
    _initializeFirestore();
    _listenToInvoices();
  }
}
