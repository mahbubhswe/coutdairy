import 'package:get/get.dart';

import '../modules/layout/controllers/layout_controller.dart';
import '../modules/court_dairy/screens/account_activation_screen.dart';

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

  /// Ensures the account is active before performing an action.
  /// Navigates to [AccountActivationScreen] and returns false if inactive.
  static bool check() {
    if (isActive()) return true;
    Get.to(() => AccountActivationScreen());
    return false;
  }
}

