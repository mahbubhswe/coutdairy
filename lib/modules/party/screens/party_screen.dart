import 'package:court_dairy/widgets/data_not_found.dart';

import '../widgets/party_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../layout/controllers/layout_controller.dart';
import '../controllers/party_controller.dart';
import 'party_profile_screen.dart';
import 'all_party_screen.dart';

class PartyScreen extends StatelessWidget {
  const PartyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PartyController());
    final layoutController = Get.put(LayoutController());
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'আপনার পক্ষসমূহ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Get.to(() => AllPartyScreen());
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  child: const Text('সব দেখুন'),
                ),
              ],
            ),
          ),
          Expanded(
            child: controller.parties.isEmpty
                ? const DataNotFound(
                    title: "দুঃখিত", subtitle: 'কোনো পক্ষ পাওয়া যায়নি')
                : ListView.builder(
                    controller: layoutController.scrollController,
                    itemCount: controller.parties.length > 10
                        ? 10
                        : controller.parties.length,
                    itemBuilder: (context, index) {
                      final party = controller.parties[index];
                      return PartyTile(
                        party: party,
                        onTap: () {
                          Get.to(() => PartyProfileScreen(party: party));
                        },
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
