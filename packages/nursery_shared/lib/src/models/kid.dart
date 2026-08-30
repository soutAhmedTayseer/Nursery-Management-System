import '../enums/kid_status.dart';

class Kid {
  const Kid({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.photoUrl,
    required this.status,
    required this.allergies,
    required this.medicalNotes,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.createdBy,
    required this.createdAt,
    required this.approvedAt,
    required this.approvedBy,
    this.qrPayload,
    this.nationality,
    this.religion,
    this.homeAddress,
  });

  final String id;
  final String fullName;
  final DateTime dateOfBirth;
  final String photoUrl;
  final KidStatus status;
  final String? allergies;
  final String? medicalNotes;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String createdBy; // 'admin' | 'guardian'
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  /// Clock-in/out QR payload for this kid.
  ///
  /// **Server-generated and server-verified** (contract §5). The client encodes
  /// it into a QR image and hands a scanned payload straight back to the
  /// check-in endpoints; it never signs or validates one itself, because a
  /// payload authorizes a real check-in that moves subscription hours and money.
  /// Null only for the fake/offline path.
  final String? qrPayload;

  /// Collected on the parent app's enrollment form; optional everywhere else,
  /// including for kids an admin creates directly.
  final String? nationality;
  final String? religion;
  final String? homeAddress;

  factory Kid.fromJson(Map<String, dynamic> json) {
    return Kid(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      // Nullable on the wire since the registration forms collect no photo
      // (contract §2). Empty string is what the app already treats as "no
      // photo", so it maps to that rather than making the field nullable and
      // rippling a null check through every widget that renders an avatar.
      photoUrl: json['photo_url'] as String? ?? '',
      status: KidStatus.fromValue(json['status'] as String),
      allergies: json['allergies'] as String?,
      medicalNotes: json['medical_notes'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String,
      emergencyContactPhone: json['emergency_contact_phone'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      approvedAt: json['approved_at'] == null
          ? null
          : DateTime.parse(json['approved_at'] as String),
      approvedBy: json['approved_by'] as String?,
      qrPayload: json['qr_payload'] as String?,
      nationality: json['nationality'] as String?,
      religion: json['religion'] as String?,
      homeAddress: json['home_address'] as String?,
    );
  }

  Kid copyWith({String? photoUrl}) => Kid(
        id: id,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        photoUrl: photoUrl ?? this.photoUrl,
        status: status,
        allergies: allergies,
        medicalNotes: medicalNotes,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        createdBy: createdBy,
        createdAt: createdAt,
        approvedAt: approvedAt,
        approvedBy: approvedBy,
        qrPayload: qrPayload,
        nationality: nationality,
        religion: religion,
        homeAddress: homeAddress,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'date_of_birth':
            '${dateOfBirth.year.toString().padLeft(4, '0')}-${dateOfBirth.month.toString().padLeft(2, '0')}-${dateOfBirth.day.toString().padLeft(2, '0')}',
        'photo_url': photoUrl,
        'status': status.value,
        'allergies': allergies,
        'medical_notes': medicalNotes,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'approved_at': approvedAt?.toIso8601String(),
        'approved_by': approvedBy,
        'qr_payload': qrPayload,
        'nationality': nationality,
        'religion': religion,
        'home_address': homeAddress,
      };
}
