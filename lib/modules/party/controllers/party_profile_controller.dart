import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/party.dart';
import '../services/party_service.dart';
import '../../../utils/activation_guard.dart';

class PartyProfileController extends GetxController {
  final Party party;
  PartyProfileController(this.party);

  final RxBool isDeleting = false.obs;
  final RxBool isSendSms = false.obs;
  final RxBool isUpdatingSms = false.obs;

  @override
  void onInit() {
    super.onInit();
    isSendSms.value = party.isSendSms;
  }

  Future<void> deleteParty() async {
    if (isDeleting.value) return;
    if (!ActivationGuard.check()) return;
    try {
      isDeleting.value = true;
      await PartyService.deleteParty(party);
      Get.back();
      Get.snackbar(
        'সফল হয়েছে',
        'পক্ষ মুছে ফেলা হয়েছে',
        backgroundColor: Colors.white,
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        'পক্ষ মুছতে ব্যর্থ হয়েছে',
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  Future<void> updateSms(bool value) async {
    if (party.docId == null || isUpdatingSms.value) return;
    if (!ActivationGuard.check()) return;
    try {
      isUpdatingSms.value = true;
      final updated = Party(
        docId: party.docId,
        name: party.name,
        phone: party.phone,
        address: party.address,
        lawyerId: party.lawyerId,
        photoUrl: party.photoUrl,
        isSendSms: value,
      );
      await PartyService.updateParty(updated);
      isSendSms.value = value;
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        'আপডেট ব্যর্থ হয়েছে',
        backgroundColor: Colors.white,
        colorText: Colors.red,
      );
    } finally {
      isUpdatingSms.value = false;
    }
  }
}
