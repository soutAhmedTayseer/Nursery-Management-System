enum SessionStatus {
  pendingConfirmation('pending_confirmation'),
  confirmed('confirmed'),
  rejected('rejected'),
  completed('completed');

  const SessionStatus(this.value);
  final String value;

  static SessionStatus fromValue(String value) {
    return SessionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown SessionStatus: $value'),
    );
  }
}
