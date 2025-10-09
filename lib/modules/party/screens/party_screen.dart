import 'package:court_dairy/widgets/data_not_found.dart';

import '../widgets/party_tile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../layout/controllers/layout_controller.dart';
import '../controllers/party_controller.dart';
import 'party_profile_screen.dart';

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
      final query = controller.searchQuery.value;
      final filteredParties = controller.filteredParties;
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
            child: filteredParties.isEmpty
                ? DataNotFound(
                    title: 'No results',
                    subtitle: query.isEmpty
                        ? 'No parties were found'
                        : 'Try adjusting your search',
                  )
                : ListView.builder(
                    controller: layoutController.scrollController,
                    itemCount: filteredParties.length > 10
                        ? 10
                        : filteredParties.length,
                    itemBuilder: (context, index) {
                      final party = filteredParties[index];
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
