/// Strong user model — stored in Firestore `students` collection.
/// Every field is documented. Backend metadata (createdAt etc.) stored
/// but NEVER shown in UI.
class UserModel {
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? examGoalId;
  final String? learningStyleId;
  final String? journeyLevelId;
  final String? profilePhotoUrl;
  final bool onboardingCompleted;
  final bool emailVerified;
  final String authProvider; // 'email', 'google', 'phone'
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.examGoalId,
    this.learningStyleId,
    this.journeyLevelId,
    this.profilePhotoUrl,
    this.onboardingCompleted = false,
    this.emailVerified = false,
    this.authProvider = 'email',
    required this.createdAt,
    this.lastLoginAt,
  });

  String get displayName => [firstName, lastName]
      .where((s) => s.isNotEmpty)
      .join(' ');

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l'.isNotEmpty ? '$f$l' : email[0].toUpperCase();
  }

  // ── Firestore serialization ──────────────────────────────────────────────

  Map<String, dynamic> toFirestore() => {
    'uid': uid,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'phoneNumber': phoneNumber,
    'dateOfBirth': dateOfBirth?.toIso8601String(),
    'examGoalId': examGoalId,
    'learningStyleId': learningStyleId,
    'journeyLevelId': journeyLevelId,
    'profilePhotoUrl': profilePhotoUrl,
    'onboardingCompleted': onboardingCompleted,
    'emailVerified': emailVerified,
    'authProvider': authProvider,
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt?.toIso8601String(),
  };

  factory UserModel.fromFirestore(Map<String, dynamic> map) => UserModel(
    uid: map['uid'] ?? '',
    email: map['email'] ?? '',
    firstName: map['firstName'] ?? '',
    lastName: map['lastName'] ?? '',
    phoneNumber: map['phoneNumber'],
    dateOfBirth: map['dateOfBirth'] != null
        ? DateTime.tryParse(map['dateOfBirth'])
        : null,
    examGoalId: map['examGoalId'],
    learningStyleId: map['learningStyleId'],
    journeyLevelId: map['journeyLevelId'],
    profilePhotoUrl: map['profilePhotoUrl'],
    onboardingCompleted: map['onboardingCompleted'] ?? false,
    emailVerified: map['emailVerified'] ?? false,
    authProvider: map['authProvider'] ?? 'email',
    createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    lastLoginAt: map['lastLoginAt'] != null
        ? DateTime.tryParse(map['lastLoginAt'])
        : null,
  );

  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? examGoalId,
    String? learningStyleId,
    String? journeyLevelId,
    String? profilePhotoUrl,
    bool? onboardingCompleted,
    bool? emailVerified,
    DateTime? lastLoginAt,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        examGoalId: examGoalId ?? this.examGoalId,
        learningStyleId: learningStyleId ?? this.learningStyleId,
        journeyLevelId: journeyLevelId ?? this.journeyLevelId,
        profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        emailVerified: emailVerified ?? this.emailVerified,
        authProvider: authProvider,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      );
}