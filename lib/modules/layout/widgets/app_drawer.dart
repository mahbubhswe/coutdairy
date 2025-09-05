import 'package:court_dairy/utils/app_date_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../court_dairy/screens/account_reset_screen.dart';
import '../controllers/layout_controller.dart';

class AppDrawer extends StatelessWidget {
  AppDrawer({super.key});

  final layoutController = Get.find<LayoutController>();
  final authController = Get.find<AuthController>();

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
                      user.displayName ?? 'User',
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

          // Compute subscription info only when lawyer doc is available
          final now = DateTime.now();
          final subscriptionEnd = lawyer?.subscriptionEndsAt;
          final daysLeft = subscriptionEnd?.difference(now).inDays;

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
                          user.displayName ?? "Not Found",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.email ?? lawyer?.phone ?? '',
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

                  // সাবস্ক্রিপশন বিস্তারিত Section
                  _sectionHeader(context, 'সাবস্ক্রিপশন বিস্তারিত'),

                  const SizedBox(height: 8),
                  // _infoTile(
                  //   context,
                  //   icon: Icons.brightness_6_rounded,
                  //   title: 'থিম পরিবর্তন',
                  //   subtitle: 'ডার্ক/লাইট মোড',
                  //   onTap: () => Get.find<ThemeController>().toggleTheme(),
                  // ),
                  const SizedBox(height: 12),
                  _infoTile(
                    context,
                    icon: CupertinoIcons.calendar,
                    title: 'মেয়াদ',
                    subtitle: '${lawyer.subFor} দিন',
                  ),
                  _infoTile(
                    context,
                    icon: CupertinoIcons.clock_fill,
                    title: 'শুরু তারিখ',
                    subtitle: lawyer.subStartsAt.formattedDate,
                  ),
                  _infoTile(
                    context,
                    icon: CupertinoIcons.timer,
                    title: 'শেষ তারিখ',
                    subtitle: subscriptionEnd!.formattedDate,
                  ),
                  _infoTile(
                    context,
                    icon: CupertinoIcons.hourglass,
                    title: 'বাকি দিন',
                    subtitle: daysLeft! > 0
                        ? '$daysLeft দিন বাকি'
                        : 'মেয়াদ শেষ',
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
            if (hasArrow)
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
