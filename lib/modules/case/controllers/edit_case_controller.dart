import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/court_case.dart';
import '../../../models/party.dart';
import '../../../services/app_firebase.dart';
import '../../party/services/party_service.dart';
import '../services/case_service.dart';
import '../../../constants/app_collections.dart';

class EditCaseController extends GetxController {
  EditCaseController(this.caseModel);

  final CourtCase caseModel;

  late final TextEditingController caseTitle;
  late final TextEditingController courtName;
  late final TextEditingController caseNumber;
  late final TextEditingController caseStatus;
  late final TextEditingController caseSummary;
  late final TextEditingController judgeName;
  late final TextEditingController courtOrder;

  final RxnString selectedCaseType = RxnString();
  final Rx<DateTime?> filedDate = Rx<DateTime?>(null);
  final Rx<DateTime?> hearingDate = Rx<DateTime?>(null);

  final Rx<Party?> selectedPlaintiff = Rx<Party?>(null);
  final Rx<Party?> selectedDefendant = Rx<Party?>(null);

  final parties = <Party>[].obs;
  final caseTypes = ['Civil', 'Criminal', 'Family', 'Other'];

  final RxBool isLoading = false.obs;

  final allCourtNames = <String>[].obs;
  final allJudgeNames = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    caseTitle = TextEditingController(text: caseModel.caseTitle);
    courtName = TextEditingController(text: caseModel.courtName);
    caseNumber = TextEditingController(text: caseModel.caseNumber);
    caseStatus = TextEditingController(text: caseModel.caseStatus);
    caseSummary = TextEditingController(text: caseModel.caseSummary);
    judgeName = TextEditingController(text: caseModel.judgeName);
    courtOrder =
        TextEditingController(text: caseModel.courtNextOrder ?? '');
    selectedCaseType.value = caseModel.caseType;
    filedDate.value = caseModel.filedDate.toDate();
    hearingDate.value = caseModel.nextHearingDate?.toDate();
    selectedPlaintiff.value = caseModel.plaintiff;
    selectedDefendant.value = caseModel.defendant;

    final user = AppFirebase().currentUser;
    if (user != null) {
      PartyService.getParties(user.uid).listen((list) {
        parties.value = list;
        _syncSelectedPartiesWithList();
      });
      _loadSuggestions(user.uid);
    }
  }

  void _syncSelectedPartiesWithList() {
    Party? _matchFromList(Party target) {
      try {
        return parties.firstWhere(
            (p) => p.name == target.name && p.phone == target.phone);
      } catch (_) {
        return null;
      }
    }

    // Ensure Dropdown `value` matches one of the `items` references
    if (caseModel.plaintiff != null) {
      selectedPlaintiff.value = _matchFromList(caseModel.plaintiff) ?? null;
    }
    if (caseModel.defendant != null) {
      selectedDefendant.value = _matchFromList(caseModel.defendant) ?? null;
    }
  }

  Future<void> _loadSuggestions(String uid) async {
    final doc = await AppFirebase()
        .firestore
        .collection(AppCollections.lawyers)
        .doc(uid)
        .get();
    final data = doc.data();
    if (data != null) {
      allCourtNames.assignAll(List<String>.from(data['courts'] ?? []));
      allJudgeNames.assignAll(List<String>.from(data['judges'] ?? []));
    }
  }

  Future<void> _updateSuggestions(
      String uid, String court, String judge) async {
    final updates = <String, dynamic>{};
    if (court.isNotEmpty && !allCourtNames.contains(court)) {
      allCourtNames.add(court);
      updates['courts'] = FieldValue.arrayUnion([court]);
    }
    if (judge.isNotEmpty && !allJudgeNames.contains(judge)) {
      allJudgeNames.add(judge);
      updates['judges'] = FieldValue.arrayUnion([judge]);
    }
    if (updates.isNotEmpty) {
      await AppFirebase()
          .firestore
          .collection(AppCollections.lawyers)
          .doc(uid)
          .update(updates);
    }
  }

  Future<bool> updateCase() async {
    final user = AppFirebase().currentUser;
    if (user == null || isLoading.value) return false;
    try {
      isLoading.value = true;
      caseModel
        ..caseType = selectedCaseType.value ?? ''
        ..caseTitle = caseTitle.text.trim()
        ..courtName = courtName.text.trim()
        ..caseNumber = caseNumber.text.trim()
        ..filedDate = Timestamp.fromDate(filedDate.value ?? DateTime.now())
        ..caseStatus = caseStatus.text.trim()
        ..plaintiff = selectedPlaintiff.value!
        ..defendant = selectedDefendant.value!
        ..nextHearingDate = hearingDate.value != null
            ? Timestamp.fromDate(hearingDate.value!)
            : null
        ..judgeName = judgeName.text.trim()
        ..courtNextOrder =
            courtOrder.text.isNotEmpty ? courtOrder.text.trim() : null
        ..caseSummary = caseSummary.text.trim();

      await CaseService.updateCase(caseModel, user.uid);
      await _updateSuggestions(
          user.uid, caseModel.courtName, caseModel.judgeName);
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
