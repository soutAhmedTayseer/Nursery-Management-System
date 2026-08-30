class AppNotification {
  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.recipientType,
    required this.type,
    required this.payload,
    required this.sentAt,
    required this.readAt,
  });

  final String id;
  final String recipientId;
  final String recipientType; // 'guardian' | 'admin'
  final String type;
  final Map<String, dynamic> payload;
  final DateTime sentAt;
  final DateTime? readAt;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      recipientId: json['recipient_id'] as String,
      recipientType: json['recipient_type'] as String,
      type: json['type'] as String,
      payload: json['payload'] as Map<String, dynamic>,
      sentAt: DateTime.parse(json['sent_at'] as String),
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipient_id': recipientId,
        'recipient_type': recipientType,
        'type': type,
        'payload': payload,
        'sent_at': sentAt.toIso8601String(),
        'read_at': readAt?.toIso8601String(),
      };
}
