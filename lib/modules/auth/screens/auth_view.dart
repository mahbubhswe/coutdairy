import 'package:court_dairy/constants/app_images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_footer.dart';
import '../../../widgets/app_text_from_field.dart';
import '../controllers/auth_controller.dart';
import 'package:auth_buttons/auth_buttons.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());

    return Scaffold(
      body: Obx(() {
        return Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(AppImages.logo, height: 150),
                    const Text(
                      'Welcome to Court Dairy',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'আপনার একাউন্টে প্রবেশ করুন',
                      style: TextStyle(fontSize: 16),
                    ),
                    AppTextFromField(
                      controller: controller.email,
                      label: "Email",
                      hintText: "Enter your Gmail address",
                      prefixIcon: HugeIcons.strokeRoundedMail02,
                    ),
                    AppTextFromField(
                      controller: controller.password,
                      label: "Password",
                      hintText: "Enter your password",
                      prefixIcon: HugeIcons.strokeRoundedLockPassword,
                      isPassword: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.forgotPassword,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    ),
                    if (controller.error.value.isNotEmpty)
                      AnimatedOpacity(
                        opacity: controller.error.value.isNotEmpty ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            border: Border.all(
                              color: Colors.red.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  controller.error.value,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    Obx(() {
                      return AppButton(
                        label: 'Login',
                        onPressed: controller.enableBtn.value
                            ? () => controller.login()
                            : null,
                      );
                    }),
                    Obx(() {
                      return GoogleAuthButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.signInWithGoogle(),
                        style: AuthButtonStyle(
                          width: double.infinity,
                          borderRadius: 12,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          buttonColor: Colors.white,
                        ),
                        text: "Sign in with Google",
                      );
                    }),
                    const SizedBox(height: 10),
                    AppFooter(),
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: Colors.teal,
                    size: 50,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
