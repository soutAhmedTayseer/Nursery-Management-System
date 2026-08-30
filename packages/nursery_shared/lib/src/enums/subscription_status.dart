enum SubscriptionStatus {
  active('active'),
  depleted('depleted'),
  expired('expired');

  const SubscriptionStatus(this.value);
  final String value;

  static SubscriptionStatus fromValue(String value) {
    return SubscriptionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Unknown SubscriptionStatus: $value'),
    );
  }
}
