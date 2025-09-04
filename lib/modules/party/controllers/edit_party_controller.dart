import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/party.dart';
import '../../../services/app_firebase.dart';
import '../services/party_service.dart';
import '../../../utils/activation_guard.dart';

class EditPartyController extends GetxController {
  final Party party;
  EditPartyController(this.party);

  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  final Rx<XFile?> photo = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = false.obs;
  final RxBool enableBtn = false.obs;
  final RxBool isSendSms = true.obs;

  @override
  void onInit() {
    super.onInit();
    name.text = party.name;
    phone.text = party.phone;
    address.text = party.address;
    isSendSms.value = party.isSendSms;

    name.addListener(_validate);
    phone.addListener(_validate);
    address.addListener(_validate);
  }

  void _validate() {
    enableBtn.value = name.text.trim().isNotEmpty &&
        phone.text.trim().isNotEmpty &&
        address.text.trim().isNotEmpty;
  }

  void showImagePicker() {
    Widget action(IconData icon, String label, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Get.theme.colorScheme.primary),
              ),
              const SizedBox(height: 8),
              Text(label),
            ],
          ),
        ),
      );
    }

    Get.bottomSheet(
      SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Get.theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    action(Icons.camera_alt_rounded, 'ক্যামেরা', () {
                      Get.back();
                      _pickImage(ImageSource.camera);
                    }),
                    action(Icons.photo_library_outlined, 'গ্যালারি', () {
                      Get.back();
                      _pickImage(ImageSource.gallery);
                    }),
                    if (photo.value != null || party.photoUrl != null)
                      action(Icons.delete_outline, 'রিমুভ', () {
                        Get.back();
                        photo.value = null;
                      }),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      photo.value = picked;
    }
  }

  Future<bool> updateParty() async {
    if (!enableBtn.value || isLoading.value) return false;
    if (!ActivationGuard.check()) return false;
    try {
      isLoading.value = true;
      final user = AppFirebase().currentUser;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      String? photoUrl = party.photoUrl;
      if (photo.value != null) {
        photoUrl = await PartyService.uploadPartyPhoto(File(photo.value!.path), user.uid);
      }

      final updated = Party(
        docId: party.docId,
        name: name.text.trim(),
        phone: phone.text.trim(),
        address: address.text.trim(),
        lawyerId: user.uid,
        photoUrl: photoUrl,
        isSendSms: isSendSms.value,
      );

      await PartyService.updateParty(updated);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    name.dispose();
    phone.dispose();
    address.dispose();
    photo.value = null;
    super.onClose();
  }
}
