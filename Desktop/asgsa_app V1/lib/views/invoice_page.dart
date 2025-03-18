import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/invoice_service.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class InvoicePage extends StatelessWidget {
  final InvoiceService _invoiceService = Get.find<InvoiceService>();

  InvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade900.withOpacity(0.8),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Mes Factures',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.blue,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                developer.log('🔄 Rafraîchissement des factures...');
                _invoiceService.refreshInvoices();
              },
            ),
          ],
        ),
        body: Obx(() {
          final invoices = _invoiceService.invoices;
          developer.log('📊 Nombre de factures dans la vue: ${invoices.length}');

          if (invoices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.blue.withOpacity(0.5),
                  ).animate()
                    .fade(duration: 800.ms)
                    .scale(delay: 400.ms),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune facture disponible',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ).animate()
                    .fade(delay: 200.ms)
                    .slideY(begin: 0.2, duration: 600.ms),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: invoices.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.white.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () => _invoiceService.downloadInvoice(invoice.id),
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 3,
                              child: Text(
                                'Facture N°${invoice.number}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.blue,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              flex: 2,
                              child: Text(
                                DateFormat('dd/MM/yyyy').format(invoice.date),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 2,
                              child: Text(
                                '${invoice.items.length} article${invoice.items.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 3,
                              child: Text(
                                'Total: ${invoice.total} DA',
                                style: TextStyle(
                                  color: Colors.blue.shade300,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  shadows: [
                                    Shadow(
                                      color: Colors.blue,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.download,
                              color: Colors.blue.shade300,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Télécharger',
                              style: TextStyle(
                                color: Colors.blue.shade300,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ).animate(
                          onPlay: (controller) => controller.repeat(),
                        )
                          .shimmer(duration: 2000.ms, color: Colors.blue.withOpacity(0.3)),
                      ],
                    ),
                  ),
                ),
              ).animate()
                .fadeIn(duration: 600.ms, delay: (100 * index).ms)
                .slideX(begin: 0.2, duration: 400.ms);
            },
          );
        }),
      ),
    );
  }
}
