enum KidStatus {
  pendingApproval('pending_approval'),
  active('active'),
  waitlisted('waitlisted'),
  inactive('inactive');

  const KidStatus(this.value);
  final String value;

  static KidStatus fromValue(String value) {
    return KidStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown KidStatus: $value'),
    );
  }
}
