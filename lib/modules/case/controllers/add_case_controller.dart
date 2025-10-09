import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/court_case.dart';
import '../../../models/party.dart';
import '../../../services/app_firebase.dart';
import '../../party/services/party_service.dart';
import '../services/case_service.dart';
import '../../../constants/app_collections.dart';
import '../../../utils/activation_guard.dart';

class AddCaseController extends GetxController {
  final caseTitle = TextEditingController();
  final courtName = TextEditingController();
  final caseNumber = TextEditingController();
  final caseSummary = TextEditingController();

  final underSection = TextEditingController();

  final judgeName = TextEditingController();
  final courtOrder = TextEditingController();
  final plaintiffName = TextEditingController();
  final plaintiffPhone = TextEditingController();

  final RxnString selectedCaseType = RxnString();
  final RxnString selectedCourtType = RxnString();
  final Rx<DateTime?> filedDate = Rx<DateTime?>(null);
  final Rx<DateTime?> hearingDate = Rx<DateTime?>(null);

  final Rx<Party?> selectedPlaintiff = Rx<Party?>(null);
  final parties = <Party>[].obs;
  final caseTypes = ['Civil', 'Criminal', 'Family', 'Other'];
  final courtTypes = ['District', 'Appeal', 'High Court'];

  final documents = <String>[].obs;

  final allCourtNames = <String>[].obs;
  final allJudgeNames = <String>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isAddingParty = false.obs;
  bool _isUpdatingPlaintiffFields = false;

  @override
  void onInit() {
    super.onInit();
    filedDate.value = DateTime.now();
    hearingDate.value = DateTime.now();
    final user = AppFirebase().currentUser;
    if (user != null) {
      PartyService.getParties(user.uid).listen((list) {
        parties.value = list;
      });
      _loadSuggestions(user.uid);
    }
    plaintiffName.addListener(_handlePlaintiffFieldChange);
    plaintiffPhone.addListener(_handlePlaintiffFieldChange);
  }

  Future<void> _loadSuggestions(String uid) async {
    final doc = await AppFirebase().firestore
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
    String uid,
    String court,
    String judge,
  ) async {
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
      await AppFirebase().firestore
          .collection(AppCollections.lawyers)
          .doc(uid)
          .update(updates);
    }
  }

  void _handlePlaintiffFieldChange() {
    if (_isUpdatingPlaintiffFields) return;
    final current = selectedPlaintiff.value;
    if (current == null) return;
    final nameMatches =
        plaintiffName.text.trim().toLowerCase() == current.name.toLowerCase();
    final phoneMatches = plaintiffPhone.text.trim() == current.phone.trim();
    if (!nameMatches || !phoneMatches) {
      selectedPlaintiff.value = null;
    }
  }

  void applyPlaintiff(Party party) {
    _isUpdatingPlaintiffFields = true;
    plaintiffName.text = party.name;
    plaintiffPhone.text = party.phone;
    _isUpdatingPlaintiffFields = false;
    selectedPlaintiff.value = party;
  }

  Future<Party?> createParty(String name, String phone) async {
    final trimmedName = name.trim();
    final trimmedPhone = phone.trim();
    if (trimmedName.isEmpty || trimmedPhone.isEmpty) return null;
    if (isAddingParty.value) return null;
    if (!ActivationGuard.check()) return null;

    final user = AppFirebase().currentUser;
    if (user == null) return null;

    try {
      isAddingParty.value = true;
      final party = Party(
        name: trimmedName,
        phone: trimmedPhone,
        address: '',
        lawyerId: user.uid,
        isSendSms: false,
      );
      final docId = await PartyService.addParty(party);
      party.docId = docId;

      applyPlaintiff(party);
      if (!parties.any((p) => p.docId == docId)) {
        parties.add(party);
      }

      return party;
    } catch (_) {
      return null;
    } finally {
      isAddingParty.value = false;
    }
  }

  Future<void> pickDocuments() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    if (files.isEmpty) return;
    final user = AppFirebase().currentUser;
    if (user == null) return;
    for (final file in files) {
      final path =
          'cases/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final ref = AppFirebase().storage.ref().child(path);
      await ref.putFile(File(file.path));
      final url = await ref.getDownloadURL();
      documents.add(url);
    }
  }

  Future<bool> addCase() async {
    if (isLoading.value) return false;
    if (!ActivationGuard.check()) return false;

    final user = AppFirebase().currentUser;
    if (user == null) return false;
    try {
      final name = plaintiffName.text.trim();
      final phone = plaintiffPhone.text.trim();
      if (name.isEmpty || phone.isEmpty) {
        Get.snackbar(
          'Missing details',
          'Enter plaintiff name and phone number',
        );
        return false;
      }

      isLoading.value = true;

      Party? plaintiff = selectedPlaintiff.value;
      final bool matchesExistingSelection =
          plaintiff != null &&
          plaintiff.name.toLowerCase() == name.toLowerCase() &&
          plaintiff.phone.trim() == phone;

      if (!matchesExistingSelection) {
        Party? existing;
        for (final party in parties) {
          if (party.name.toLowerCase() == name.toLowerCase() &&
              party.phone.trim() == phone) {
            existing = party;
            break;
          }
        }

        if (existing != null) {
          applyPlaintiff(existing);
          plaintiff = existing;
        } else {
          plaintiff = await createParty(name, phone);
          if (plaintiff == null) {
            Get.snackbar('Party unavailable', 'Unable to add the new party.');
            isLoading.value = false;
            return false;
          }
        }
      }

      final caseModel = CourtCase(
        caseType: selectedCaseType.value ?? '',
        caseTitle: caseTitle.text.trim(),
        courtType: selectedCourtType.value ?? '',
        courtName: courtName.text.trim(),
        caseNumber: caseNumber.text.trim(),
        filedDate: Timestamp.fromDate(filedDate.value ?? DateTime.now()),
        caseStatus: 'Ongoing',
        plaintiff: plaintiff!,
        underSection: underSection.text.trim().isEmpty
            ? null
            : underSection.text.trim(),
        nextHearingDate: hearingDate.value != null
            ? Timestamp.fromDate(hearingDate.value!)
            : null,
        judgeName: judgeName.text.trim(),
        documentsAttached: documents.toList(),
        courtNextOrder: courtOrder.text.isNotEmpty
            ? courtOrder.text.trim()
            : null,
        caseSummary: caseSummary.text.trim(),
      );

      await CaseService.addCase(caseModel, user.uid);
      await _updateSuggestions(
        user.uid,
        caseModel.courtName,
        caseModel.judgeName,
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    caseTitle.dispose();
    courtName.dispose();
    caseNumber.dispose();
    caseSummary.dispose();
    underSection.dispose();
    judgeName.dispose();
    courtOrder.dispose();
    plaintiffName.removeListener(_handlePlaintiffFieldChange);
    plaintiffName.dispose();
    plaintiffPhone.removeListener(_handlePlaintiffFieldChange);
    plaintiffPhone.dispose();
    super.onClose();
  }
}
