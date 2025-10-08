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
    final layoutController = Get.find<LayoutController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return Column(
        children: [
          Expanded(
            child: controller.parties.isEmpty
                ? const DataNotFound(
                    title: 'No results', subtitle: 'No parties were found')
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
