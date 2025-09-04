import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/party.dart';
import '../../../widgets/app_info_row.dart';
import '../controllers/party_profile_controller.dart';
import 'edit_party_screen.dart';
import 'party_transactions_screen.dart';
import 'party_cases_screen.dart';
import '../../../utils/activation_guard.dart';
import '../../accounts/controllers/transaction_controller.dart';
import '../../case/controllers/case_controller.dart';
import 'package:intl/intl.dart';

class PartyProfileScreen extends StatelessWidget {
  final Party party;
  const PartyProfileScreen({super.key, required this.party});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PartyProfileController(party));
    final caseController = Get.isRegistered<CaseController>()
        ? Get.find<CaseController>()
        : Get.put(CaseController());
    final txController = Get.isRegistered<TransactionController>()
        ? Get.find<TransactionController>()
        : Get.put(TransactionController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('পক্ষ প্রোফাইল'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                if (ActivationGuard.check()) {
                  Get.to(() => EditPartyScreen(party: party));
                }
              } else if (value == 'delete') {
                if (ActivationGuard.check()) {
                  controller.deleteParty();
                }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('এডিট')),
              PopupMenuItem(value: 'delete', child: Text('ডিলিট')),
            ],
          ),
        ],
      ),
      body: Obx(() {
        final theme = Theme.of(context);
        return SafeArea(
          top: false,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Header card with avatar and name
                    Container(
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: (party.photoUrl != null &&
                                    party.photoUrl!.isNotEmpty)
                                ? NetworkImage(party.photoUrl!)
                                : null,
                            child: (party.photoUrl == null ||
                                    party.photoUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 48)
                                : null,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            party.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.phone_iphone, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                party.phone,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Details card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0.5,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 20),
                                const SizedBox(width: 8),
                                Expanded(child: appInfoRow('নাম', party.name)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              children: [
                                const Icon(Icons.call_outlined, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: appInfoRow('মোবাইল', party.phone)),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: appInfoRow('ঠিকানা', party.address)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Case & Transaction summary card
                    Obx(() {
                      int caseCount = 0;
                      double txTotal = 0;
                      // Match cases by name+phone (case embeds Party without id)
                      bool matchesParty(a, b) =>
                          a.name == b.name && a.phone == b.phone;
                      if (!caseController.isLoading.value) {
                        caseCount = caseController.cases
                            .where((c) =>
                                matchesParty(c.plaintiff, party) ||
                                matchesParty(c.defendant, party))
                            .length;
                      }
                      if (!txController.isLoading.value) {
                        txTotal = txController.transactions
                            .where((t) => t.partyId == party.docId)
                            .fold(0.0, (sum, t) => sum + (t.amount));
                      }
                      final amountText = NumberFormat.currency(
                        locale: 'bn_BD',
                        symbol: '৳',
                        decimalDigits: 0,
                      ).format(txTotal);
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0.5,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.insights_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('ওভারভিউ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const Divider(height: 20),
                              appInfoRow('মোট কেস', caseCount.toString()),
                              const Divider(height: 20),
                              appInfoRow('মোট পেমেন্ট', amountText),
                            ],
                          ),
                        ),
                      );
                    }),

                    // Navigate to Party Transactions (from body)
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0.5,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: const Icon(Icons.receipt_long_rounded),
                            title: const Text('লেনদেন দেখুন'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Get.to(
                                  () => PartyTransactionsScreen(party: party));
                            },
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: const Icon(Icons.gavel_rounded),
                            title: const Text('কেস দেখুন'),
                            trailing: const Icon(Icons.chevron_right_rounded),
                            onTap: () {
                              Get.to(() => PartyCasesScreen(party: party));
                            },
                          )
                        ],
                      ),
                    ),

                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0.5,
                      child: Obx(() => SwitchListTile(
                            title: const Text('এসএমএস নোটিফায়ার'),
                            value: controller.isSendSms.value,
                            onChanged: controller.updateSms,
                          )),
                    ),
                  ],
                ),
              ),
              if (controller.isDeleting.value || controller.isUpdatingSms.value)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      }),
    );
  }
}
