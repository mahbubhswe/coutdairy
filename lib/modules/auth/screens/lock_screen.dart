import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/local_auth_controller.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocalAuthController>();
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (controller.isAuthenticating.value) {
            return const CircularProgressIndicator();
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 64),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.authenticate,
                child: const Text('অথেন্টিকেশন করুন'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: const Text('অ্যাপ থেকে বের হন'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
