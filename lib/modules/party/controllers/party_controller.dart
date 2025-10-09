import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/party.dart';
import '../../../services/app_firebase.dart';
import '../services/party_service.dart';

class PartyController extends GetxController {
  final RxList<Party> parties = <Party>[].obs;
  final RxBool isLoading = true.obs;
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

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

  List<Party> get filteredParties {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return parties;
    return parties.where((party) {
      final name = party.name.toLowerCase();
      final phone = party.phone.toLowerCase();
      return name.contains(query) || phone.contains(query);
    }).toList();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void clearSearch() {
    if (searchController.text.isEmpty) return;
    searchController.clear();
    searchQuery.value = '';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
