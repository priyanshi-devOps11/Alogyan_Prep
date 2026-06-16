import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore user document — collection: 'students'
class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? dob;
  final String? selectedExamGoalId;
  final String? selectedLearningStyleId;
  final String? selectedJourneyLevelId;
  final bool isOnboardingCompleted;
  final String authProvider; // 'email' | 'google' | 'phone'

  const UserModel({
    required this.uid,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phoneNumber,
    this.dob,
    this.selectedExamGoalId,
    this.selectedLearningStyleId,
    this.selectedJourneyLevelId,
    this.isOnboardingCompleted = false,
    this.authProvider = 'email',
  });

  String get displayName {
    final n = [firstName, lastName]
        .where((s) => s.isNotEmpty)
        .join(' ');
    return n.isNotEmpty ? n : email;
  }

  Map<String, dynamic> toFirestoreMap({bool isNew = false}) {
    final map = <String, dynamic>{
      'uid':                     uid,
      'email':                   email,
      'firstName':               firstName,
      'lastName':                lastName,
      'phoneNumber':             phoneNumber,
      'dob':                     dob,
      'selectedExamGoalId':      selectedExamGoalId,
      'selectedLearningStyleId': selectedLearningStyleId,
      'selectedJourneyLevelId':  selectedJourneyLevelId,
      'isOnboardingCompleted':   isOnboardingCompleted,
      'authProvider':            authProvider,
      'lastUpdated':             FieldValue.serverTimestamp(),
    };
    if (isNew) map['createdAt'] = FieldValue.serverTimestamp();
    return map;
  }

  factory UserModel.fromFirestore(Map<String, dynamic> map) => UserModel(
    uid:                     (map['uid']   as String?)  ?? '',
    email:                   (map['email'] as String?)  ?? '',
    firstName:               (map['firstName'] as String?) ?? '',
    lastName:                (map['lastName']  as String?) ?? '',
    phoneNumber:             map['phoneNumber'] as String?,
    dob:                     map['dob'] as String?,
    selectedExamGoalId:      map['selectedExamGoalId']      as String?,
    selectedLearningStyleId: map['selectedLearningStyleId'] as String?,
    selectedJourneyLevelId:  map['selectedJourneyLevelId']  as String?,
    isOnboardingCompleted:   (map['isOnboardingCompleted'] as bool?) ?? false,
    authProvider:            (map['authProvider'] as String?) ?? 'email',
  );

  UserModel copyWith({
    String? firstName, String? lastName, String? phoneNumber, String? dob,
    String? selectedExamGoalId, String? selectedLearningStyleId,
    String? selectedJourneyLevelId, bool? isOnboardingCompleted,
  }) => UserModel(
    uid: uid, email: email, authProvider: authProvider,
    firstName:               firstName               ?? this.firstName,
    lastName:                lastName                ?? this.lastName,
    phoneNumber:             phoneNumber             ?? this.phoneNumber,
    dob:                     dob                     ?? this.dob,
    selectedExamGoalId:      selectedExamGoalId      ?? this.selectedExamGoalId,
    selectedLearningStyleId: selectedLearningStyleId ?? this.selectedLearningStyleId,
    selectedJourneyLevelId:  selectedJourneyLevelId  ?? this.selectedJourneyLevelId,
    isOnboardingCompleted:   isOnboardingCompleted   ?? this.isOnboardingCompleted,
  );
}