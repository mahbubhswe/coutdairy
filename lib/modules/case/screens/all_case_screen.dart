import 'package:court_dairy/widgets/data_not_found.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/case_controller.dart';
import '../widgets/case_tile.dart';

class AllCaseScreen extends StatelessWidget {
  AllCaseScreen({super.key});

  final controller = Get.find<CaseController>();
  final RxString typeFilter = 'All'.obs;
  final RxString courtFilter = 'All'.obs;

  @override
  Widget build(BuildContext context) {
    final appBarColor = Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.primary;
    return Scaffold(
      appBar: AppBar(title: const Text('সমস্ত কেস')),
      body: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Obx(() {
              final uniqueTypes =
                  controller.cases.map((c) => c.caseType).toSet().toList();
              final uniqueCourts =
                  controller.cases.map((c) => c.courtType).toSet().toList();
              final types = ['All', ...uniqueTypes];
              final courts = ['All', ...uniqueCourts];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('কেসের ধরন',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: types.map((t) {
                        final selected = typeFilter.value == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                                t == 'All' ? 'সব' : t,
                                style: const TextStyle(fontSize: 12)),
                            selected: selected,
                            onSelected: (_) => typeFilter.value = t,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    selected ? Colors.transparent : appBarColor,
                              ),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Text('আদালতের ধরন',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: courts.map((t) {
                        final selected = courtFilter.value == t;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(
                                t == 'All' ? 'সব' : t,
                                style: const TextStyle(fontSize: 12)),
                            selected: selected,
                            onSelected: (_) => courtFilter.value = t,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    selected ? Colors.transparent : appBarColor,
                              ),
                            ),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }),
          ),
          Expanded(
            child: Obx(() {
              final filtered = controller.cases.where((c) {
                final typeMatch =
                    typeFilter.value == 'All' || c.caseType == typeFilter.value;
                final courtMatch = courtFilter.value == 'All' ||
                    c.courtType == courtFilter.value;
                return typeMatch && courtMatch;
              }).toList();

              if (filtered.isEmpty) {
                return const DataNotFound(
                    title: 'দুঃখিত', subtitle: 'কোনো কেস পাওয়া যায়নি');
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return CaseTile(caseItem: item);
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
