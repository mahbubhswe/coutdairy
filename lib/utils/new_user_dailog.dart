import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../modules/layout/screens/layout_screen.dart';
import '../modules/party/screens/add_party_screen.dart';

void showNewUserDialog() {
  Future.delayed(const Duration(seconds: 5), () {
    if (Get.context != null) {
      Get.dialog(
        Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.card_giftcard, size: 60, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  'অভিনন্দন!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'আপনি ৩০ দিনের ফ্রি ট্রায়েল পেয়েছেন।\n'
                  'Court Diary এর সকল ফিচার ব্যবহার করে দেখুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await Get.offAll(() => const LayoutScreen());
                      Get.to(() => const AddPartyScreen(),
                          fullscreenDialog: true);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('ব্যবহার শুরু করুন'),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    }
  });
}
