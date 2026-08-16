import 'dart:io';

import 'package:nursery_shared/nursery_shared.dart';

import 'kids_repository.dart';

class ApiKidsRepository implements KidsRepository {
  ApiKidsRepository(this._client);

  final ApiClient _client;

  @override
  Future<PaginatedResult<Kid>> fetchKids({
    int page = 1,
    int pageSize = 20,
    KidStatus? status,
    String query = '',
  }) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/kids',
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        if (status != null) 'status': status.value,
        if (query.trim().isNotEmpty) 'query': query.trim(),
      },
    );
    return PaginatedResult.fromJson(response.data!, Kid.fromJson);
  }

  @override
  Future<Kid> fetchKid(String id) => _kid(_client.get('/kids/$id'));

  @override
  Future<Kid> createKid({
    required String fullName,
    required DateTime dateOfBirth,
    required String emergencyContactName,
    required String emergencyContactPhone,
    String? allergies,
    String? medicalNotes,
    String? photoUrl,
  }) {
    // No id and no qr_payload in the body: the server owns both (contract §5).
    return _kid(_client.post('/kids', data: {
      'full_name': fullName,
      'date_of_birth': _date(dateOfBirth),
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'allergies': allergies,
      'medical_notes': medicalNotes,
      'photo_url': ?photoUrl,
    }));
  }

  @override
  Future<Kid> updateKid(
    String id, {
    String? fullName,
    String? allergies,
    String? medicalNotes,
    String? photoUrl,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    // Only the fields actually passed are sent, so a PATCH never blanks a
    // column the caller did not mean to touch.
    return _kid(_client.patch('/kids/$id', data: {
      'full_name': ?fullName,
      'allergies': ?allergies,
      'medical_notes': ?medicalNotes,
      'photo_url': ?photoUrl,
      'emergency_contact_name': ?emergencyContactName,
      'emergency_contact_phone': ?emergencyContactPhone,
    }));
  }

  @override
  Future<String> uploadPhoto(String filePath) async {
    _validate(filePath);
    final response = await _client.postMultipart<Map<String, dynamic>>(
      '/uploads',
      filePath: filePath,
    );
    return response.data!['url'] as String;
  }

  /// Rejects a file the server would reject anyway, before spending the upload.
  /// Throws the same `VALIDATION_ERROR` the server would, so the calling code
  /// and its error message do not care which side caught it.
  static void _validate(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    if (!kAcceptedImageExtensions.contains(extension)) {
      throw const ApiException(
        code: 'VALIDATION_ERROR',
        message: 'Unsupported image type',
        statusCode: 400,
      );
    }

    final file = File(filePath);
    if (file.existsSync() && file.lengthSync() > kMaxUploadBytes) {
      throw const ApiException(
        code: 'VALIDATION_ERROR',
        message: 'Image is larger than 5 MB',
        statusCode: 400,
      );
    }
  }

  @override
  Future<Kid> approve(String id) => _kid(_client.post('/admin/kids/$id/approve'));

  @override
  Future<Kid> reject(String id, {required String reason}) =>
      _kid(_client.post('/admin/kids/$id/reject', data: {'reason': reason}));

  @override
  Future<Kid> waitlist(String id) => _kid(_client.post('/admin/kids/$id/waitlist'));

  @override
  Future<Kid> activate(String id) => _kid(_client.post('/admin/kids/$id/activate'));

  @override
  Future<Kid> deactivate(String id) => _kid(_client.post('/admin/kids/$id/deactivate'));

  /// Every write returns the updated kid, so they all decode the same way.
  /// Typed on the response's `data` rather than dio's `Response`, which feature
  /// code does not import (root AGENTS.md §7).
  Future<Kid> _kid(Future<dynamic> call) async => Kid.fromJson((await call).data!);

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
