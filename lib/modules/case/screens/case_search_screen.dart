import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/case_controller.dart';
import '../widgets/case_tile.dart';

class CaseSearchScreen extends StatefulWidget {
  const CaseSearchScreen({super.key});

  @override
  State<CaseSearchScreen> createState() => _CaseSearchScreenState();
}

class _CaseSearchScreenState extends State<CaseSearchScreen> {
  final RxString query = ''.obs;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode()..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    query.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CaseController>();
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final inputTheme = theme.inputDecorationTheme;
    final Color baseBackground =
        inputTheme.fillColor ?? cs.surface;
    final Color focusedBackground =
        inputTheme.focusColor ?? baseBackground;
    final Color background =
        _focusNode.hasFocus ? focusedBackground : baseBackground;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        titleSpacing: 0,
        toolbarHeight: 64,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: 42,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              cursorColor: cs.primary,
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: 'Search cases',
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 20,
                ),
                suffixIcon: Obx(() {
                  return query.value.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          onPressed: () {
                            _controller.clear();
                            query.value = '';
                          },
                          icon: Icon(
                            Icons.close,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          tooltip: 'Clear',
                        );
                }),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 20,
                ),
              ),
              onChanged: (v) => query.value = v.toLowerCase(),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final q = query.value;
        final results = controller.cases.where((c) {
          final title = c.caseTitle.toLowerCase();
          final number = c.caseNumber.toLowerCase();
          final plaintiff = c.plaintiff.name.toLowerCase();
          final underSection = (c.underSection ?? '').toLowerCase();
          final pPhone = c.plaintiff.phone.toLowerCase();
          return title.contains(q) ||
              number.contains(q) ||
              plaintiff.contains(q) ||
              underSection.contains(q) ||
              pPhone.contains(q);
        }).toList();
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (_, i) => CaseTile(caseItem: results[i]),
        );
      }),
    );
  }
}
