import 'package:court_dairy/widgets/data_not_found.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

import '../controllers/case_controller.dart';
import '../widgets/case_tile.dart';
import 'case_search_screen.dart';

class CaseScreen extends StatefulWidget {
  const CaseScreen({super.key});

  @override
  State<CaseScreen> createState() => _CaseScreenState();
}

class _CaseScreenState extends State<CaseScreen> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _chipScrollController = ScrollController();
  bool _showFilters = true;
  final Map<String, GlobalKey> _chipKeys = {};

  void _handleScroll() {
    if (!_scrollController.hasClients) return;

    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _showFilters) {
      setState(() => _showFilters = false);
    } else if (direction == ScrollDirection.forward && !_showFilters) {
      setState(() => _showFilters = true);
    }

    if (_scrollController.offset <= 0 && !_showFilters) {
      setState(() => _showFilters = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _chipScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaseController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final surfaceColor = colorScheme.surfaceVariant;
    final chipContainerColor = colorScheme.surface;
    final accentColor = colorScheme.secondary;
    final mutedTextColor = colorScheme.onSurfaceVariant;

    return Container(
      color: backgroundColor,
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_showFilters) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () => Get.to(() => CaseSearchScreen()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: mutedTextColor),
                          const SizedBox(width: 12),
                          Text(
                            'Search cases…',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: mutedTextColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  controller: _chipScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _filterChip(
                      context: context,
                      controller: controller,
                      keyValue: 'today',
                      label: "Today (${controller.todayCount})",
                      surfaceColor: chipContainerColor,
                      selectedColor: accentColor,
                    ),
                    _filterChip(
                      context: context,
                      controller: controller,
                      keyValue: 'tomorrow',
                      label: 'Tomorrow (${controller.tomorrowCount})',
                      surfaceColor: chipContainerColor,
                      selectedColor: accentColor,
                    ),
                    _filterChip(
                      context: context,
                      controller: controller,
                      keyValue: 'week',
                      label: 'This Week (${controller.weekCount})',
                      surfaceColor: chipContainerColor,
                      selectedColor: accentColor,
                    ),
                    _filterChip(
                      context: context,
                      controller: controller,
                      keyValue: 'month',
                      label: 'This Month (${controller.monthCount})',
                      surfaceColor: chipContainerColor,
                      selectedColor: accentColor,
                    ),
                    _filterChip(
                      context: context,
                      controller: controller,
                      keyValue: 'new',
                      label: 'New Cases (${controller.newCount})',
                      surfaceColor: chipContainerColor,
                      selectedColor: accentColor,
                    ),
                    _filterChip(
                      context: context,
                      controller: controller,
                      keyValue: 'running',
                      label: 'Ongoing Cases (${controller.runningCount})',
                      surfaceColor: chipContainerColor,
                      selectedColor: accentColor,
                    ),
                    _filterChip(
                      context: context,
                      controller: controller,
                      keyValue: 'closed',
                      label: 'Closed Cases (${controller.closedCount})',
                      surfaceColor: chipContainerColor,
                      selectedColor: accentColor,
                    ),
                    _filterChip(
                      context: context,
                      controller: controller,
                      keyValue: 'all',
                      label: 'All Cases (${controller.totalCount})',
                      surfaceColor: chipContainerColor,
                      selectedColor: accentColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: controller.filteredCases.isEmpty
                    ? const Center(
                        key: ValueKey('empty_cases'),
                        child: DataNotFound(
                          title: "No results",
                          subtitle: "No cases were found",
                        ),
                      )
                    : ListView.builder(
                        key: ValueKey(controller.selectedFilter.value),
                        physics: const BouncingScrollPhysics(),
                        controller: _scrollController,
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: controller.filteredCases.length,
                        itemBuilder: (_, i) {
                          final caseItem = controller.filteredCases[i];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 300),
                            builder: (context, value, child) =>
                                Opacity(opacity: value, child: child),
                            child: CaseTile(caseItem: caseItem),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _filterChip({
    required BuildContext context,
    required CaseController controller,
    required String keyValue,
    required String label,
    required Color surfaceColor,
    required Color selectedColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selected = controller.selectedFilter.value == keyValue;
    final chipKey = _chipKeys.putIfAbsent(
      keyValue,
      () => GlobalKey(debugLabel: keyValue),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        key: chipKey,
        child: ChoiceChip(
          label: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected
                  ? colorScheme.onSecondary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          selected: selected,
          onSelected: (isSelected) {
            if (!isSelected) return;
            controller.selectedFilter.value = keyValue;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final context = chipKey.currentContext;
              final box = context?.findRenderObject() as RenderBox?;
              if (context != null && box != null) {
                final position = box.localToGlobal(Offset.zero).dx;
                final width = box.size.width;
                final screenWidth = MediaQuery.of(context).size.width;
                const padding = 16.0;
                double? targetOffset;

                if (position < padding) {
                  targetOffset =
                      _chipScrollController.offset + position - padding;
                } else if (position + width > screenWidth - padding) {
                  targetOffset =
                      _chipScrollController.offset +
                      (position + width - (screenWidth - padding));
                }

                if (targetOffset != null) {
                  _chipScrollController.animateTo(
                    targetOffset.clamp(
                      _chipScrollController.position.minScrollExtent,
                      _chipScrollController.position.maxScrollExtent,
                    ),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  );
                }
              }
            });
          },
          selectedColor: selectedColor,
          backgroundColor: surfaceColor,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: selected
                  ? selectedColor
                  : colorScheme.outlineVariant.withOpacity(0.6),
            ),
          ),
          showCheckmark: false,
        ),
      ),
    );
  }
}
