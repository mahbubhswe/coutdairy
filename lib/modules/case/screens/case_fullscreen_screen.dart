import 'package:court_dairy/modules/case/screens/case_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

import 'case_screen.dart';

class CaseFullscreenScreen extends StatelessWidget {
  const CaseFullscreenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('আপনার কেস'),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => CaseSearchScreen());
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(HugeIcons.strokeRoundedArrowShrink),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: const CaseScreen(showHeader: false),
      ),
    );
  }
}
