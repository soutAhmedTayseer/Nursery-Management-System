import 'package:flutter_test/flutter_test.dart';
import 'package:nursery_shared/nursery_shared.dart';

void main() {
  test('Kid round-trips JSON including nullable fields', () {
    final json = {
      'id': 'k1',
      'full_name': 'Youssef',
      'date_of_birth': '2021-03-10',
      'photo_url': 'https://cdn.example.com/k1.jpg',
      'status': 'active',
      'allergies': 'peanuts',
      'medical_notes': null,
      'emergency_contact_name': 'Sara Ahmed',
      'emergency_contact_phone': '+201000000000',
      'created_by': 'admin',
      'created_at': '2026-01-15T10:00:00.000Z',
      'approved_at': '2026-01-15T11:00:00.000Z',
      'approved_by': 'a1',
      // Server-generated (contract §5) — present on every read.
      'qr_payload': 'k1.server-signed',
      'nationality': 'Egyptian',
      'religion': null,
      'home_address': '12 Corniche St, Cairo',
    };

    final kid = Kid.fromJson(json);

    expect(kid.status, KidStatus.active);
    expect(kid.photoUrl, 'https://cdn.example.com/k1.jpg');
    expect(kid.medicalNotes, isNull);
    expect(kid.toJson(), json);
  });

  test('Kid handles null approval fields for a pending kid', () {
    final json = {
      'id': 'k2',
      'full_name': 'Layla',
      'date_of_birth': '2022-06-01',
      'photo_url': 'https://cdn.example.com/k2.jpg',
      'status': 'pending_approval',
      'allergies': null,
      'medical_notes': null,
      'emergency_contact_name': 'Omar',
      'emergency_contact_phone': '+201000000001',
      'created_by': 'guardian',
      'created_at': '2026-01-20T10:00:00.000Z',
      'approved_at': null,
      'approved_by': null,
      'qr_payload': 'k2.server-signed',
      'nationality': null,
      'religion': null,
      'home_address': null,
    };

    final kid = Kid.fromJson(json);

    expect(kid.status, KidStatus.pendingApproval);
    expect(kid.approvedAt, isNull);
    expect(kid.toJson(), json);
  });
}
