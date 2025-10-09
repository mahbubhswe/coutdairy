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
      appBar: AppBar(title: const Text('All parties')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final query = controller.searchQuery.value;
        final parties = controller.filteredParties;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final surfaceColor = colorScheme.surfaceContainerHighest;
        final mutedTextColor = colorScheme.onSurfaceVariant;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: mutedTextColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.updateSearch,
                          textInputAction: TextInputAction.search,
                          cursorColor: mutedTextColor,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: mutedTextColor),
                          decoration: InputDecoration(
                            hintText: 'Search parties…',
                            hintStyle: theme.textTheme.bodyMedium
                                ?.copyWith(color: mutedTextColor),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (query.isNotEmpty)
                        IconButton(
                          onPressed: controller.clearSearch,
                          tooltip: 'Clear search',
                          icon: Icon(Icons.close, color: mutedTextColor),
                          splashRadius: 18,
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: parties.isEmpty
                  ? DataNotFound(
                      title: 'No results',
                      subtitle: query.isEmpty
                          ? 'No parties were found'
                          : 'Try adjusting your search',
                    )
                  : ListView.builder(
                      itemCount: parties.length,
                      itemBuilder: (context, index) {
                        final party = parties[index];
                        return PartyTile(
                          party: party,
                          onTap: () =>
                              Get.to(() => PartyProfileScreen(party: party)),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
