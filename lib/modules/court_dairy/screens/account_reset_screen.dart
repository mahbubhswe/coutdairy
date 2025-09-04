import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../constants/app_collections.dart';
import '../../../services/app_firebase.dart';

class AccountResetController extends GetxController {
  final isResetting = false.obs;
  final holdProgress = 0.0.obs; // 0..1 for the fill animation

  Timer? _timer;
  DateTime? _start;

  void startHold() {
    if (isResetting.value) return;
    _start = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (t) {
      final elapsed = DateTime.now().difference(_start!).inMilliseconds;
      final p = (elapsed / 3000).clamp(0.0, 1.0);
      holdProgress.value = p;
      if (p >= 1.0) {
        t.cancel();
        _triggerReset();
      }
    });
  }

  void cancelHold() {
    if (isResetting.value) return;
    _timer?.cancel();
    holdProgress.value = 0.0;
  }

  Future<void> _triggerReset() async {
    if (isResetting.value) return;
    isResetting.value = true;
    try {
      HapticFeedback.heavyImpact();
      await _resetAllData();
      Get.snackbar('Done', 'All cases, parties and transactions deleted.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.black);
    } finally {
      isResetting.value = false;
      holdProgress.value = 0.0;
    }
  }

  Future<void> _resetAllData() async {
    final user = AppFirebase().currentUser;
    if (user == null) {
      throw Exception('Not logged in');
    }
    final fs = AppFirebase().firestore;
    final root = fs.collection(AppCollections.lawyers).doc(user.uid);

    Future<void> purgeCollection(String name) async {
      final col = root.collection(name);
      while (true) {
        final snap = await col.limit(400).get();
        if (snap.docs.isEmpty) break;
        final batch = fs.batch();
        for (final d in snap.docs) {
          batch.delete(d.reference);
        }
        await batch.commit();
      }
    }

    await purgeCollection(AppCollections.cases);
    await purgeCollection(AppCollections.parties);
    await purgeCollection(AppCollections.transactions);
  }
}

class AccountResetScreen extends StatelessWidget {
  const AccountResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final ctrl = Get.put(AccountResetController());
    final dangerColor = Colors.red.shade600;
    final dangerTextColor = Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Reset'),
        iconTheme: IconThemeData(color: cs.onPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 25,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: dangerColor, size: 100),
            Text(
              'Danger Zone',
              style: theme.textTheme.titleLarge?.copyWith(
                color: dangerTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'এই অ্যাকাউন্ট রিসেট করলে আপনার সব ডেটা মুছে যাবে — '
                    'সকল কেস, পার্টি ও ট্রান্সাকশন স্থায়ীভাবে ডিলিট হবে। '
                    'এই কাজটি বাতিল করা যাবে না।',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _DangerChip(label: 'Cases'),
                      _DangerChip(label: 'Parties'),
                      _DangerChip(label: 'Transactions'),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() {
              final p = ctrl.holdProgress.value;
              final resetting = ctrl.isResetting.value;
              final timeLeft = (3 - (p * 3)).clamp(0.0, 3.0);
              return GestureDetector(
                onTapDown: (_) => ctrl.startHold(),
                onTapUp: (_) => ctrl.cancelHold(),
                onTapCancel: () => ctrl.cancelHold(),
                child: Stack(
                  children: [
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: dangerColor, width: 1.6),
                        color: cs.surface,
                        boxShadow: [
                          BoxShadow(
                            color: dangerColor.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: p, // 0..1 fill
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [dangerColor, Colors.red.shade400],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.delete_forever,
                                size: 22,
                                color:
                                    p > 0.5 ? Colors.white : dangerTextColor),
                            const SizedBox(width: 8),
                            Text(
                              resetting
                                  ? 'Resetting...'
                                  : (p <= 0
                                      ? 'Hold to RESET account (3.0s)'
                                      : 'Keep holding... (${timeLeft.toStringAsFixed(1)}s)'),
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: p > 0.5 ? Colors.white : dangerTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (resetting)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _DangerChip extends StatelessWidget {
  final String label;
  const _DangerChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final color = Colors.red.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
        color: color.withOpacity(0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

