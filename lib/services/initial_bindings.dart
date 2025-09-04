import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/layout/controllers/layout_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(LayoutController());
  }
}
