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

    Widget section(String title, Widget child) {
      return SizedBox(
        width: double.infinity,
        child: Card(
          elevation: 0.5,
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
          title: 'Confirm',
          message: 'Do you want to delete the case?',
          confirmButtonText: 'Yes',
          cancelButtonText: 'No',
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
        title: Text('${caseItem.caseTitle}(${caseItem.caseNumber})'),
        actions: [
          PopupMenuButton<String>(
            onSelected: handleMenu,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
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
                                'Latest: '
                                '${last != null ? last.toDate().formattedDate : '-'}',
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Next: '
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
                                          title: 'Confirm',
                                          message:
                                              'Update the next hearing date?',
                                          confirmButtonText: 'Yes',
                                          cancelButtonText: 'No',
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
                                                      ? 'Next hearing date updated'
                                                      : 'Failed to update',
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
                                    tooltip: 'Update next hearing',
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
                    'Court order',
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
                              Text('Latest: ${last ?? '-'}'),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Next: ${next ?? '-'}',
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
                                              'Update next order',
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
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                  ctx,
                                                  controllerText.text.trim(),
                                                ),
                                                child: const Text('Update'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      final text = result?.trim();
                                      if (text == null || text.isEmpty) return;
                                      PanaraConfirmDialog.show(
                                        context,
                                        title: 'Confirm',
                                        message: 'Update the next order?',
                                        confirmButtonText: 'Yes',
                                        cancelButtonText: 'No',
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
                                                    ? 'Next order updated'
                                                    : 'Failed to update',
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
                                    tooltip: 'Update next order',
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
                    'Case information',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appInfoRow('Case type', caseItem.caseType),
                        const SizedBox(height: 8),
                        appInfoRow('Court type', caseItem.courtType),
                        const SizedBox(height: 8),
                        if (caseItem.underSection?.isNotEmpty == true) ...[
                          appInfoRow('Under section', caseItem.underSection!),
                          const SizedBox(height: 8),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Case status',
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
                    'Court information',
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        appInfoRow('Court name', caseItem.courtName),
                        const SizedBox(height: 8),
                        appInfoRow(
                          'Judge',
                          caseItem.judgeName.isEmpty ? '-' : caseItem.judgeName,
                        ),
                      ],
                    ),
                  ),

                  // Parties
                  section(
                    'Party',
                    Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(caseItem.plaintiff.name),
                          subtitle: Text('Plaintiff\n${caseItem.plaintiff.address}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(HugeIcons.strokeRoundedCall02),
                            tooltip: 'Call plaintiff',
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
                    'Case status',
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
                          labelText: 'Case status',
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
                          PanaraConfirmDialog.show(
                            context,
                            title: 'Confirm',
                            message: 'Change the case status to "$v"?',
                            confirmButtonText: 'Yes',
                            cancelButtonText: 'No',
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
                                        ? 'Status updated'
                                        : 'Status update failed',
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
                    'Filed date',
                    appInfoRow(
                      'Filed date',
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
