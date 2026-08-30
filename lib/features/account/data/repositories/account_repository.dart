import '../models/account.dart';

/// The signed-in admin's own profile and password.
///
/// Implementations throw `ApiException` (nursery_shared) on failure.
abstract class AccountRepository {
  Future<Account> fetchMe();

  /// `PUT /api/account/me` then re-reads, so callers always get the
  /// server's view back.
  Future<Account> updateMe({
    required String fullName,
    required String phoneNumber,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
