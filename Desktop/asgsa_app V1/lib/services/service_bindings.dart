import 'package:get/get.dart';
import 'invoice_service.dart';
import 'cart_service.dart';

class ServiceBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(InvoiceService(), permanent: true);
    Get.put(CartService(), permanent: true);
  }
}
