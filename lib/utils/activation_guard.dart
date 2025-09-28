import 'package:get/get.dart';
import 'package:court_dairy/modules/court_dairy/screens/screens.dart';
import 'package:court_dairy/modules/layout/controllers/layout_controller.dart';

class ActivationGuard {
  /// Returns true if the current lawyer account is active.
  static bool isActive() {
    try {
      final layout = Get.find<LayoutController>();
      return layout.lawyer.value?.isActive ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Navigates to [AccountActivationScreen] and returns false if inactive.
  static bool check() {
    if (isActive()) return true;
    Get.to(() => AccountActivationScreen());
    return false;
  }
}

