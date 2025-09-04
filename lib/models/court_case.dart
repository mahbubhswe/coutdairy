import 'package:court_dairy/services/firebase_export.dart';

import 'party.dart';

class CourtCase {
  // docId: Frontend unique identifier (only used in the frontend)
  String? docId;

  // Case Information
  String caseType;
  String caseTitle;
  final String courtType;
  String courtName;
  String caseNumber;
  Timestamp filedDate; // Use Timestamp instead of DateTime
  String caseStatus;

  // Plaintiff and Defendant Information
  Party plaintiff;
  Party defendant;

  // Hearing Dates
  Timestamp? lastHearingDate; // Firestore Timestamp
  Timestamp? nextHearingDate; // Firestore Timestamp

  // Judge Information
  String judgeName;

  // Documents Attached
  List<String> documentsAttached;

  // Court Orders
  String? courtLastOrder;
  String? courtNextOrder;

  // Case Summary
  String caseSummary;

  // Constructor
  CourtCase({
    this.docId,
    required this.caseType,
    required this.caseTitle,
    required this.courtType,
    required this.courtName,
    required this.caseNumber,
    required this.filedDate,
    required this.caseStatus,
    required this.plaintiff,
    required this.defendant,
    this.lastHearingDate,
    this.nextHearingDate,
    required this.judgeName,
    required this.documentsAttached,
    this.courtLastOrder,
    this.courtNextOrder,
    required this.caseSummary,
  });

  // Method to convert the case data to a map (for Firebase storage)
  Map<String, dynamic> toMap() {
    return {
      'caseType': caseType,
      'caseTitle': caseTitle,
      'courtType': courtType,
      'courtName': courtName,
      'caseNumber': caseNumber,
      'filedDate': filedDate, // Firestore Timestamp will be directly saved
      'caseStatus': caseStatus,
      'plaintiff': plaintiff.toMap(),
      'defendant': defendant.toMap(),
      'lastHearingDate': lastHearingDate,
      'nextHearingDate': nextHearingDate,
      'judgeName': judgeName,
      'documentsAttached': documentsAttached,
      'courtLastOrder': courtLastOrder,
      'courtNextOrder': courtNextOrder,
      'caseSummary': caseSummary,
    };
  }

  // Method to convert a map to a CourtCase object (for fetching data from Firebase)
  factory CourtCase.fromMap(Map<String, dynamic> map, {String? docId}) {
    return CourtCase(
      docId: docId,
      caseType: map['caseType'],
      caseTitle: map['caseTitle'],
      courtType: map['courtType'],
      courtName: map['courtName'],
      caseNumber: map['caseNumber'],
      filedDate: map['filedDate'], // Firestore Timestamp
      caseStatus: map['caseStatus'],
      plaintiff: Party.fromMap(map['plaintiff']),
      defendant: Party.fromMap(map['defendant']),
      lastHearingDate: map['lastHearingDate'],
      nextHearingDate: map['nextHearingDate'],
      judgeName: map['judgeName'],
      documentsAttached: List<String>.from(map['documentsAttached']),
      courtLastOrder: map['courtLastOrder'],
      courtNextOrder: map['courtNextOrder'],
      caseSummary: map['caseSummary'],
    );
  }
}
