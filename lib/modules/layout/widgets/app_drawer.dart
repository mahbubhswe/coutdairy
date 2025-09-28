import 'package:court_dairy/themes/theme_controller.dart';
import 'package:court_dairy/utils/app_date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/controllers/local_auth_controller.dart';
import '../../auth/screens/app_lock_screen.dart';
import '../../auth/services/pin_lock_service.dart';
import '../../court_dairy/screens/account_reset_screen.dart';
import '../controllers/layout_controller.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final layoutController = Get.find<LayoutController>();
  final authController = Get.find<AuthController>();
  final localAuthController = Get.find<LocalAuthController>();
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor; // Match app background
    final navColor = bg; // Keep system nav consistent with drawer bg
    final navIconsBrightness =
        ThemeData.estimateBrightnessForColor(navColor) == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    return Drawer(
      width: width,
      backgroundColor: bg,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: navColor,
          systemNavigationBarIconBrightness: navIconsBrightness,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
        child: Obx(() {
          final lawyer = layoutController.lawyer.value;
          final user = authController.user.value;

          if (user == null) {
            return const Center(child: CupertinoActivityIndicator(radius: 15));
          }

          // If lawyer document is missing or not yet loaded, show a minimal drawer
          if (lawyer == null) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(CupertinoIcons.chevron_back),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: user.photoURL != null
                          ? CachedNetworkImageProvider(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Text(
                              (user.displayName ?? '?')
                                  .trim()
                                  .characters
                                  .take(1)
                                  .toString()
                                  .toUpperCase(),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName ?? 'ব্যবহারকারী',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    const CupertinoActivityIndicator(radius: 12),
                  ],
                ),
              ),
            );
          }



          final lastSignIn = user.metadata.lastSignInTime;
          final formattedSignIn = lastSignIn != null
              ? lastSignIn.formattedDateTime
              : 'অজানা';

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button with rounded bg
                  Align(
                    alignment: Alignment.topLeft,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          CupertinoIcons.chevron_back,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Profile Info - Column layout with photo, name, email
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surface,
                          backgroundImage: user.photoURL != null
                              ? CachedNetworkImageProvider(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                                  user.displayName != null &&
                                          user.displayName!.isNotEmpty
                                      ? user.displayName![0].toUpperCase()
                                      : '?',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                )
                              : null,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          user.displayName ?? "নেই",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.email ?? lawyer.phone,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(CupertinoIcons.clock, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'সর্বশেষ লগইন: $formattedSignIn',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  _sectionHeader(context, 'অ্যাপ সেটিংস'),
                  const SizedBox(height: 8),
                  Obx(() {
                    final enabled = localAuthController.isEnabled.value;
                    return _infoTile(
                      context,
                      icon: Icons.lock,
                      title: 'লোকাল অথেন্টিকেশন',
                      subtitle: enabled ? 'চালু' : 'বন্ধ',
                      onTap: () => localAuthController.toggle(!enabled),
                      trailing: Switch.adaptive(
                        value: enabled,
                        onChanged: (v) => localAuthController.toggle(v),
                      ),
                    );
                  }),
                  Obx(() {
                    final isDarkMode = themeController.isDarkMode;
                    return _infoTile(
                      context,
                      icon: isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      title: 'থিম মোড',
                      subtitle:
                          isDarkMode ? 'ডার্ক মোড সক্রিয়' : 'লাইট মোড সক্রিয়',
                      onTap: themeController.toggleTheme,
                      trailing: Switch.adaptive(
                        value: isDarkMode,
                        onChanged: (_) => themeController.toggleTheme(),
                      ),
                    );
                  }),
                  _infoTile(
                    context,
                    icon: Icons.password,
                    title: 'পিন পরিবর্তন করুন',
                    subtitle: 'অ্যাপ লকের পিন আপডেট করুন',
                    hasArrow: true,
                    onTap: () async {
                      final hasPin = await PinLockService.isPinSet();
                      if (hasPin) {
                        final verified = await Get.to(() => const AppLockScreen());
                        if (verified != true) return;
                      }
                      final created = await Get.to(() => const AppLockScreen(setupMode: true));
                      if (created == true) {
                        Get.snackbar('সফল হয়েছে', 'পিন সফলভাবে আপডেট হয়েছে', snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),
                  _infoTile(
                    context,
                    icon: Icons.lock_reset,
                    title: 'পিন রিসেট করুন',
                    subtitle: 'অ্যাপ লকের পিন মুছে ফেলুন',
                    onTap: () async {
                      // Require current PIN before allowing reset
                      final verified = await Get.to(() => const AppLockScreen());
                      if (verified != true) return;
                      final confirm = await showCupertinoDialog<bool>(
                        context: context,
                        builder: (ctx) => CupertinoAlertDialog(
                          title: const Text('পিন রিসেট করবেন?'),
                          content: const Text('এতে আপনার অ্যাপের পিন মুছে যাবে। পরে নতুন পিন সেট করতে পারবেন।'),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('বাতিল'),
                              onPressed: () => Navigator.of(ctx).pop(false),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text('রিসেট'),
                              onPressed: () => Navigator.of(ctx).pop(true),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await PinLockService.clearPin();
                        if (localAuthController.isEnabled.value) {
                          await localAuthController.toggle(false);
                        }
                        Get.snackbar('পিন মুছে ফেলা হয়েছে', 'যেকোনো সময় নতুন পিন সেট করতে পারেন', snackPosition: SnackPosition.BOTTOM);
                      }
                    },
                  ),

                  const SizedBox(height: 36),

                  // সাবস্ক্রিপশন বিস্তারিত Section
                  _sectionHeader(context, 'সাবস্ক্রিপশন বিস্তারিত'),

                  const SizedBox(height: 8),
              
                  _infoTile(
                    context,
                    icon: CupertinoIcons.calendar,
                    title: 'মেয়াদ',
                    subtitle:
                        '${lawyer.subEndsAt.difference(lawyer.subStartsAt).inDays} দিন',
                  ),

                  _infoTile(
                    context,
                    icon: CupertinoIcons.clock_fill,
                    title: 'শুরু তারিখ',
                    subtitle: DateFormat().format(lawyer.subStartsAt),
                  ),
                  _infoTile(
                    context,
                    icon: CupertinoIcons.timer,
                    title: 'শেষ তারিখ',
                    subtitle: DateFormat().format(lawyer.subEndsAt),
                  ),
           

                  const SizedBox(height: 36),

                  // Reset Section
                  _sectionHeader(context, 'রিসেট অপশন'),
                  const SizedBox(height: 12),
                  // Removed password reset from drawer as requested
                  _infoTile(
                    context,
                    icon: Icons.account_balance_wallet,
                    title: 'অ্যাকাউন্ট রিসেট',
                    subtitle: 'অ্যাকাউন্ট রিসেট করুন',
                    onTap: () => Get.to((AccountResetScreen())),
                  ),

                  const SizedBox(height: 36),

                  // Logout (outlined, themed destructive style)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      label: Text(
                        'লগ আউট',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showCupertinoDialog<bool>(
                          context: context,
                          builder: (ctx) => CupertinoAlertDialog(
                            title: const Text('লগ আউট নিশ্চিত করুন'),
                            content: const Text(
                              'আপনি কি সত্যিই লগ আউট করতে চান?',
                            ),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('বাতিল'),
                                onPressed: () => Navigator.of(ctx).pop(false),
                              ),
                              CupertinoDialogAction(
                                isDestructiveAction: true,
                                child: const Text('লগ আউট'),
                                onPressed: () => Navigator.of(ctx).pop(true),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await authController.logout();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? subtitleColor,
    bool isBold = false,
    bool hasArrow = false,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12), // Rounded rectangle bg
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: subtitleColor,
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (hasArrow)
              Icon(
                CupertinoIcons.chevron_forward,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}
