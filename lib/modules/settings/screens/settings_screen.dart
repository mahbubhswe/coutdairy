import 'package:cached_network_image/cached_network_image.dart';
import 'package:court_dairy/modules/auth/controllers/auth_controller.dart';
import 'package:court_dairy/modules/auth/controllers/local_auth_controller.dart';
import 'package:court_dairy/modules/auth/screens/app_lock_screen.dart';
import 'package:court_dairy/modules/auth/services/pin_lock_service.dart';
import 'package:court_dairy/modules/court_dairy/screens/account_reset_screen.dart';
import 'package:court_dairy/modules/court_dairy/screens/buy_sms_screen.dart';
import 'package:court_dairy/modules/layout/controllers/layout_controller.dart';
import 'package:court_dairy/themes/theme_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final layoutController = Get.find<LayoutController>();
  final authController = Get.find<AuthController>();
  final localAuthController = Get.find<LocalAuthController>();
  final themeController = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final navColor = bg;
    final navIconsBrightness =
        ThemeData.estimateBrightnessForColor(navColor) == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
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

        if (lawyer == null) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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

        final smsBalanceText = NumberFormat.decimalPattern(
          'en',
        ).format(lawyer.smsBalance);
        final dateFormatter = DateFormat('dd MMM,yyyy');
        final subscriptionStart = dateFormatter.format(lawyer.subStartsAt);
        final subscriptionEnd = dateFormatter.format(lawyer.subEndsAt);

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant,
                      backgroundImage: user.photoURL != null
                          ? CachedNetworkImageProvider(user.photoURL!)
                          : null,
                      child: user.photoURL == null
                          ? Text(
                              user.displayName != null &&
                                      user.displayName!.isNotEmpty
                                  ? user.displayName![0].toUpperCase()
                                  : '?',
                              style: Theme.of(context).textTheme.headlineMedium,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user.displayName ?? "Not available",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.email ?? lawyer.phone,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _sectionHeader(context, 'Subscription'),
                const SizedBox(height: 12),
                _infoTile(
                  context,
                  icon: CupertinoIcons.money_dollar_circle,
                  title: 'SMS balance',
                  subtitle: '$smsBalanceText remaining',
                  subtitleColor: Theme.of(
                    context,
                  ).colorScheme.primary.withOpacity(0.8),
                  isBold: true,
                  hasArrow: true,
                  onTap: () => Get.to(() => BuySmsView()),
                ),
                _infoTile(
                  context,
                  icon: CupertinoIcons.calendar,
                  title: 'Subscription duration',
                  subtitle:
                      '${lawyer.subEndsAt.difference(lawyer.subStartsAt).inDays} days',
                ),
                _infoTile(
                  context,
                  icon: CupertinoIcons.clock_fill,
                  title: 'Start date',
                  subtitle: subscriptionStart,
                ),
                _infoTile(
                  context,
                  icon: CupertinoIcons.timer,
                  title: 'End date',
                  subtitle: subscriptionEnd,
                ),
                const SizedBox(height: 28),
                _sectionHeader(context, 'Security'),
                const SizedBox(height: 12),
                Obx(() {
                  final isDarkMode = themeController.isDarkMode;
                  return _infoTile(
                    context,
                    icon: isDarkMode
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    title: 'Theme mode',
                    subtitle:
                        isDarkMode ? 'Dark mode enabled' : 'Light mode enabled',
                    onTap: themeController.toggleTheme,
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      onChanged: (_) => themeController.toggleTheme(),
                    ),
                  );
                }),
                Obx(() {
                  final enabled = localAuthController.isEnabled.value;
                  return _infoTile(
                    context,
                    icon: Icons.lock,
                    title: 'Local authentication',
                    subtitle: enabled ? 'Enabled' : 'Disabled',
                    onTap: () => localAuthController.toggle(!enabled),
                    trailing: Switch.adaptive(
                      value: enabled,
                      onChanged: (v) => localAuthController.toggle(v),
                    ),
                  );
                }),
                _infoTile(
                  context,
                  icon: Icons.password,
                  title: 'Change PIN',
                  subtitle: 'Update the app lock PIN',
                  hasArrow: true,
                  onTap: () async {
                    final hasPin = await PinLockService.isPinSet();
                    if (hasPin) {
                      final verified = await Get.to(
                        () => const AppLockScreen(),
                      );
                      if (verified != true) return;
                    }
                    final created = await Get.to(
                      () => const AppLockScreen(setupMode: true),
                    );
                    if (created == true) {
                      Get.snackbar(
                        'Success',
                        'PIN updated successfully',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
                _infoTile(
                  context,
                  icon: Icons.lock_reset,
                  title: 'Reset PIN',
                  subtitle: 'Remove the app lock PIN',
                  onTap: () async {
                    final verified = await Get.to(() => const AppLockScreen());
                    if (verified != true) return;
                    final confirm = await showCupertinoDialog<bool>(
                      context: context,
                      builder: (ctx) => CupertinoAlertDialog(
                        title: const Text('Reset PIN?'),
                        content: const Text(
                          'This will remove the app PIN. You can set a new PIN later.',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            child: const Text('Cancel'),
                            onPressed: () => Navigator.of(ctx).pop(false),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            child: const Text('Reset'),
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
                      Get.snackbar(
                        'PIN removed',
                        'You can set a new PIN any time',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),
                const SizedBox(height: 28),
                _sectionHeader(context, 'Reset options'),
                const SizedBox(height: 12),
                _infoTile(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: 'Account reset',
                  subtitle: 'Reset the account',
                  onTap: () => Get.to(() => AccountResetScreen()),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(
                      Icons.logout,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    label: Text(
                      'Log out',
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
                          title: const Text('Confirm log out'),
                          content: const Text(
                            'Are you sure you want to log out?',
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('Cancel'),
                              onPressed: () => Navigator.of(ctx).pop(false),
                            ),
                            CupertinoDialogAction(
                              isDestructiveAction: true,
                              child: const Text('Log out'),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLight = theme.brightness == Brightness.light;
    final iconBackgroundColor = isLight
        ? colorScheme.secondaryContainer
        : colorScheme.surfaceContainerHighest;
    final iconForegroundColor = isLight
        ? colorScheme.onSecondaryContainer
        : colorScheme.onSurfaceVariant;

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
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconForegroundColor),
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
