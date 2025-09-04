import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../controllers/case_controller.dart';
import 'cases_on_date_screen.dart';

class CaseCalendarScreen extends StatelessWidget {
  CaseCalendarScreen({super.key});

  final _caseController = Get.find<CaseController>();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final firstWeekday = DateTime(now.year, now.month, 1).weekday; // 1 = Monday

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('কেস ক্যালেন্ডার'),
        actions: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(HugeIcons.strokeRoundedArrowShrink),
          ),
        ],
      ),
      body: Obx(() {
        final mq = MediaQuery.of(context);
        final size = mq.size;
        final isCompact = size.height < 720 || size.width < 380;
        final outerHPad = isCompact ? 12.0 : 16.0;
        final gridSpacing = isCompact ? 4.0 : 6.0;
        final cellPad = isCompact ? 4.0 : 8.0;
        final weekdayVPad = isCompact ? 4.0 : 6.0;
        final aspect = isCompact ? 1.3 : 1.0; // >1 shrinks height
        final counts = _caseController.monthCaseCounts;
        final totalCells = daysInMonth + firstWeekday - 1;
        final monthLabel = DateFormat('MMMM yyyy').format(now);
        final weekdays = const ['সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি', 'রবি'];

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(outerHPad, 12, outerHPad, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    monthLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  // Simple legend
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(color: Colors.green.shade600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('কেস আছে', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            // Weekday headers
            Padding(
              padding: EdgeInsets.symmetric(horizontal: outerHPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (i) {
                  return Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: weekdayVPad),
                        child: Text(
                          weekdays[i],
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 4),
            // Calendar grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(outerHPad, 0, outerHPad, 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                  childAspectRatio: aspect,
                ),
                itemCount: totalCells,
                itemBuilder: (context, index) {
                  if (index < firstWeekday - 1) {
                    return const SizedBox.shrink();
                  }
                  final day = index - (firstWeekday - 1) + 1;
                  final count = counts[day] ?? 0;
                  final hasCase = count > 0;
                  final isToday = now.day == day;

                  final baseBorder =
                      Theme.of(context).colorScheme.outlineVariant;
                  final bgColor = hasCase
                      ? Colors.green.withOpacity(0.18)
                      : Theme.of(context).colorScheme.surface;
                  final borderColor = hasCase
                      ? Colors.green.shade600
                      : (isToday
                          ? Theme.of(context).colorScheme.primary
                          : baseBorder);

                  return InkWell(
                    onTap: hasCase
                        ? () {
                            final selected = DateTime(now.year, now.month, day);
                            Get.to(() => CasesOnDateScreen(date: selected));
                          }
                        : null,
                    child: Container(
                      decoration: BoxDecoration(
                      color: bgColor,
                      border: Border.all(
                          color: borderColor, width: isToday ? 1.5 : 1),
                      borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
                      ),
                      child: Padding(
                      padding: EdgeInsets.all(cellPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                day.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: hasCase
                                      ? Colors.green.shade800
                                      : Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                  fontSize: isCompact ? 11 : null,
                                ),
                              ),
                              if (hasCase)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCompact ? 5 : 6,
                                    vertical: isCompact ? 1 : 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: isCompact ? 9.5 : 11,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (!isCompact) ...[
                            const Spacer(),
                            Text(
                              hasCase ? '$count টি কেস' : '',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: hasCase
                                        ? Colors.green.shade800
                                        : Theme.of(context).hintColor,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      ),
                    ),
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
