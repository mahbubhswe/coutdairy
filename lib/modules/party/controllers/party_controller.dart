import 'package:get/get.dart';

import '../../../models/party.dart';
import '../../../services/app_firebase.dart';
import '../services/party_service.dart';

class PartyController extends GetxController {
  final RxList<Party> parties = <Party>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadParties();
  }

  void _loadParties() {
    final user = AppFirebase().currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    PartyService.getParties(user.uid).listen((data) {
      parties.value = data;
      isLoading.value = false;
    });
  }
}

