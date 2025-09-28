import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/court_case.dart';
import '../../../widgets/app_info_row.dart';
import '../../../utils/activation_guard.dart';
import '../../../utils/app_date_formatter.dart';
import '../../../services/app_firebase.dart';
import '../services/case_service.dart';
import '../controllers/case_controller.dart';
import 'edit_case_screen.dart';

class CaseDetailScreen extends StatelessWidget {
  CaseDetailScreen(this.caseItem, {super.key});

  final CourtCase caseItem;
  final RxBool isDeleting = false.obs;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaseController>();
    final theme = Theme.of(context);
    final statuses = const ['Ongoing', 'Disposed', 'Completed'];

    Widget chip(String text, {Color? color, IconData? icon}) {
      return Chip(
        avatar: icon != null
            ? Icon(icon, size: 18, color: theme.colorScheme.onPrimary)
            : null,
        label: Text(text, style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: color ?? theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      );
    }

    Widget section(String title, Widget child) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.15),
              theme.colorScheme.primary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      );
    }

    Color _statusBgColor(String status) {
      switch (status.toLowerCase()) {
        case 'ongoing':
          return Colors.white;
        case 'disposed':
          return Colors.red;
        case 'completed':
          return Colors.green;
        default:
          return theme.colorScheme.secondary;
      }
    }

    Color _statusTextColor(String status) {
      switch (status.toLowerCase()) {
        case 'ongoing':
          return Colors.black;
        case 'disposed':
        case 'completed':
          return Colors.white;
        default:
          return theme.colorScheme.onSecondary;
      }
    }

    Future<void> handleMenu(String value) async {
      if (value == 'edit') {
        if (ActivationGuard.check()) {
          Get.to(() => EditCaseScreen(caseItem));
        }
      } else if (value == 'delete') {
        if (!ActivationGuard.check()) return;
        final id = caseItem.docId;
        if (id == null) return;
        PanaraConfirmDialog.show(
          context,
          title: 'নিশ্চিত করুন',
          message: 'কেস মুছে ফেলতে চান?',
          confirmButtonText: 'হ্যাঁ',
          cancelButtonText: 'না',
          onTapCancel: () => Navigator.of(context).pop(),
          onTapConfirm: () async {
            Navigator.of(context).pop();
            isDeleting.value = true;
            await controller.deleteCase(id);
            isDeleting.value = false;
            Get.back();
          },
          panaraDialogType: PanaraDialogType.warning,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(caseItem.caseTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: handleMenu,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('সম্পাদনা')),
              PopupMenuItem(value: 'delete', child: Text('মুছে ফেলুন')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                spacing: 5,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header summary - gradient container (same as profile screen)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.15),
                          theme.colorScheme.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 8,
                      children: [
                        Text(
                          caseItem.caseTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.gavel_outlined, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'কেস নং: ${caseItem.caseNumber}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        if (caseItem.caseType.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.category_outlined, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'কেস টাইপ: ${caseItem.caseType}',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Dates (moved up)
                  section(
                    'Hearings Dates',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final current = controller.cases.firstWhere(
                            (c) => c.docId == caseItem.docId,
                            orElse: () => caseItem,
                          );
                          final last = current.lastHearingDate;
                          final next = current.nextHearingDate;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'সর্বশেষ: '
                                '${last != null ? last.toDate().formattedDate : '-'}',
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'পরবর্তী: '
                                      '${next != null ? next.toDate().formattedDate : '-'}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      if (!ActivationGuard.check()) return;
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        PanaraConfirmDialog.show(
                                          context,
                                          title: 'নিশ্চিত করুন',
                                          message:
                                              'নেক্সট হিয়ারিং ডেট আপডেট করবেন?',
                                          confirmButtonText: 'হ্যাঁ',
                                          cancelButtonText: 'না',
                                          onTapCancel: () =>
                                              Navigator.of(context).pop(),
                                          onTapConfirm: () async {
                                            Navigator.of(context).pop();
                                            bool ok = false;
                                            try {
                                              final user =
                                                  AppFirebase().currentUser;
                                              final id = caseItem.docId;
                                              if (user != null && id != null) {
                                                await CaseService.updateNextHearingDate(
                                                  id,
                                                  user.uid,
                                                  Timestamp.fromDate(picked),
                                                );
                                                ok = true;
                                              }
                                            } catch (_) {}
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  ok
                                                      ? 'নেক্সট হিয়ারিং ডেট আপডেট হয়েছে'
                                                      : 'আপডেট করতে ব্যর্থ',
                                                ),
                                              ),
                                            );
                                          },
                                          panaraDialogType:
                                              PanaraDialogType.normal,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      HugeIcons.strokeRoundedCalendar01,
                                    ),
                                    tooltip: 'পরবর্তী শুনানি আপডেট',
                                    iconSize: 20,
                                    splashRadius: 20,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 36,
                                      height: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  // Court Orders (moved up)
                  section(
                    'আদালতের আদেশ',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final current = controller.cases.firstWhere(
                            (c) => c.docId == caseItem.docId,
                            orElse: () => caseItem,
                          );
                          final last = current.courtLastOrder;
                          final next = current.courtNextOrder;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('সর্বশেষ: ${last ?? '-'}'),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'পরবর্তী: ${next ?? '-'}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      if (!ActivationGuard.check()) return;
                                      final controllerText =
                                          TextEditingController();
                                      final result = await showDialog<String>(
                                        context: context,
                                        builder: (ctx) {
                                          return AlertDialog(
                                            title: const Text(
                                              'পরবর্তী আদেশ আপডেট',
                                            ),
                                            content: TextField(
                                              controller: controllerText,
                                              decoration: const InputDecoration(
                                                hintText: 'Enter next order',
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('বাতিল'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  ctx,
                                                  controllerText.text.trim(),
                                                ),
                                                child: const Text('আপডেট'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      final text = result?.trim();
                                      if (text == null || text.isEmpty) return;
                                      PanaraConfirmDialog.show(
                                        context,
                                        title: 'নিশ্চিত করুন',
                                        message: 'নেক্সট অর্ডার আপডেট করবেন?',
                                        confirmButtonText: 'হ্যাঁ',
                                        cancelButtonText: 'না',
                                        onTapCancel: () =>
                                            Navigator.of(context).pop(),
                                        onTapConfirm: () async {
                                          Navigator.of(context).pop();
                                          bool ok = false;
                                          try {
                                            final user =
                                                AppFirebase().currentUser;
                                            final id = caseItem.docId;
                                            if (user != null && id != null) {
                                              await CaseService.setCourtNextOrder(
                                                id,
                                                user.uid,
                                                text,
                                              );
                                              ok = true;
                                            }
                                          } catch (_) {}
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                ok
                                                    ? 'নেক্সট অর্ডার আপডেট হয়েছে'
                                                    : 'আপডেট করতে ব্যর্থ',
                                              ),
                                            ),
                                          );
                                        },
                                        panaraDialogType:
                                            PanaraDialogType.normal,
                                      );
                                    },
                                    icon: const Icon(
                                      HugeIcons.strokeRoundedEdit03,
                                    ),
                                    tooltip: 'পরবর্তী আদেশ আপডেট',
                                    iconSize: 20,
                                    splashRadius: 20,
                                    constraints: const BoxConstraints.tightFor(
                                      width: 36,
                                      height: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  // Case Information
                  section(
                    'কেস তথ্য',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appInfoRow('কেসের ধরন', caseItem.caseType),
                        const SizedBox(height: 8),
                        appInfoRow('আদালতের ধরন', caseItem.courtType),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'কেসের অবস্থা',
                              style: TextStyle(fontSize: 14),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: _statusBgColor(caseItem.caseStatus),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                caseItem.caseStatus,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: _statusTextColor(caseItem.caseStatus),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Court Information
                  section(
                    'আদালত তথ্য',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appInfoRow('আদালতের নাম', caseItem.courtName),
                        const SizedBox(height: 8),
                        appInfoRow(
                          'বিচারক',
                          caseItem.judgeName.isEmpty ? '-' : caseItem.judgeName,
                        ),
                      ],
                    ),
                  ),

                  // Parties
                  section(
                    'পক্ষসমূহ',
                    Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(caseItem.plaintiff.name),
                          subtitle: Text('বাদী\n${caseItem.plaintiff.address}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(HugeIcons.strokeRoundedCall02),
                            tooltip: 'বাদীকে কল করুন',
                            onPressed: (caseItem.plaintiff.phone.isEmpty)
                                ? null
                                : () async {
                                    final uri = Uri(
                                      scheme: 'tel',
                                      path: caseItem.plaintiff.phone,
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                          ),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(caseItem.defendant.name),
                          subtitle: Text(
                            'বিবাদী\n${caseItem.defendant.address}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(HugeIcons.strokeRoundedCall02),
                            tooltip: 'বিবাদীকে কল করুন',
                            onPressed: (caseItem.defendant.phone.isEmpty)
                                ? null
                                : () async {
                                    final uri = Uri(
                                      scheme: 'tel',
                                      path: caseItem.defendant.phone,
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Summary
                  section(
                    'Summary',
                    Text(
                      caseItem.caseSummary.isEmpty ? '-' : caseItem.caseSummary,
                    ),
                  ), // Documents
                  section(
                    'Documents',
                    caseItem.documentsAttached.isEmpty
                        ? const Text('-')
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: caseItem.documentsAttached.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                ),
                            itemBuilder: (context, index) {
                              final url = caseItem.documentsAttached[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(url, fit: BoxFit.cover),
                              );
                            },
                          ),
                  ),

                  // Case Status (inline update)
                  section(
                    'কেসের অবস্থা',
                    Obx(() {
                      final current = controller.cases.firstWhere(
                        (c) => c.docId == caseItem.docId,
                        orElse: () => caseItem,
                      );
                      return DropdownButtonFormField<String>(
                        value: current.caseStatus.isEmpty
                            ? null
                            : current.caseStatus,
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(12),
                        menuMaxHeight: 320,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        decoration: InputDecoration(
                          labelText: 'কেসের অবস্থা',
                          hintText: 'Select case status',
                          prefixIcon: const Icon(Icons.flag_outlined),
                          filled: true,
                          fillColor: theme.colorScheme.surface.withOpacity(0.7),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        items: statuses
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) async {
                          if (v == null) return;
                          final old = current.caseStatus;
                          PanaraConfirmDialog.show(
                            context,
                            title: 'নিশ্চিত করুন',
                            message: 'কেস স্ট্যাটাস "$v" এ পরিবর্তন করবেন?',
                            confirmButtonText: 'হ্যাঁ',
                            cancelButtonText: 'না',
                            onTapCancel: () {
                              Navigator.of(context).pop();
                              // revert visual selection
                              controller.cases.refresh();
                            },
                            onTapConfirm: () async {
                              Navigator.of(context).pop();
                              bool ok = false;
                              try {
                                final user = AppFirebase().currentUser;
                                final id = caseItem.docId;
                                if (user != null && id != null) {
                                  await CaseService.updateCaseStatus(
                                    id,
                                    user.uid,
                                    v,
                                  );
                                  ok = true;
                                }
                              } catch (_) {}
                              if (!ok) {
                                controller.cases.refresh();
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ok
                                        ? 'স্ট্যাটাস আপডেট হয়েছে'
                                        : 'স্ট্যাটাস আপডেট ব্যর্থ',
                                  ),
                                ),
                              );
                            },
                            panaraDialogType: PanaraDialogType.normal,
                          );
                        },
                      );
                    }),
                  ),

                  // Filed Date (separate section at bottom)
                  section(
                    'Filed Date',
                    appInfoRow(
                      'Filed Date',
                      caseItem.filedDate.toDate().formattedDate,
                    ),
                  ),
                ],
              ),
            ),
            // overlay loader
            Obx(
              () => isDeleting.value
                  ? Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
