import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/party_controller.dart';
import '../widgets/party_tile.dart';
import 'party_profile_screen.dart';
import '../../../widgets/data_not_found.dart';

class AllPartyScreen extends StatelessWidget {
  AllPartyScreen({super.key});

  final controller = Get.find<PartyController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Parties')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.parties.isEmpty) {
          return const DataNotFound(title: 'Sorry', subtitle: 'No Party Found');
        }
        return ListView.builder(
          itemCount: controller.parties.length,
          itemBuilder: (context, index) {
            final party = controller.parties[index];
            return PartyTile(
              party: party,
              onTap: () => Get.to(() => PartyProfileScreen(party: party)),
            );
          },
        );
      }),
    );
  }
}

