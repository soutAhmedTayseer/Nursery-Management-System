class ChildSessionModel {
  final String id;
  final String name;
  final String image;
  final String subscription;
  final bool isCheckedIn;
  final String? duration;

  ChildSessionModel({
    required this.id,
    required this.name,
    required this.image,
    required this.subscription,
    required this.isCheckedIn,
    this.duration,
  });
}
