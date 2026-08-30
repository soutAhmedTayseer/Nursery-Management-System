import 'package:nursery_shared/nursery_shared.dart';

import '../models/account.dart';
import 'account_repository.dart';

class ApiAccountRepository implements AccountRepository {
  ApiAccountRepository(this.client);

  final ApiClient client;

  @override
  Future<Account> fetchMe() async {
    final response = await client.get<Map<String, dynamic>>('/account/me');
    return Account.fromJson(response.data ?? const <String, dynamic>{});
  }

  @override
  Future<Account> updateMe({
    required String fullName,
    required String phoneNumber,
  }) async {
    await client.put<dynamic>(
      '/account/me',
      data: {'fullName': fullName, 'phoneNumber': phoneNumber},
    );
    // The contract for PUT /account/me does not pin a response body, so
    // re-read rather than trust the echo.
    return fetchMe();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await client.put<dynamic>(
      '/account/password',
      data: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }
}
