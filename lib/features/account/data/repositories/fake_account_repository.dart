import '../../../../core/testing/fake_failure_switch.dart';
import '../models/account.dart';
import 'account_repository.dart';

/// In-memory admin profile for the demo build and tests.
class FakeAccountRepository implements AccountRepository {
  FakeAccountRepository({
    required this.failureSwitch,
    this.latency = const Duration(milliseconds: 300),
  });

  final FakeFailureSwitch failureSwitch;
  final Duration latency;

  Account _account = const Account(
    id: 'fake-admin',
    fullName: 'Admin',
    userName: 'superadmin',
    role: 'SuperAdmin',
    phoneNumber: '01119450425',
  );

  @override
  Future<Account> fetchMe() async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
    return _account;
  }

  @override
  Future<Account> updateMe({
    required String fullName,
    required String phoneNumber,
  }) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
    _account = _account.copyWith(fullName: fullName, phoneNumber: phoneNumber);
    return _account;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
  }
}
