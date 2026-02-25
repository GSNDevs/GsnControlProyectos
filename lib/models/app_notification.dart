class AppNotification {
  final String id;
  final String recipientId;
  final String message;
  final String? relatedProjectId;
  final bool read;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.recipientId,
    required this.message,
    this.relatedProjectId,
    this.read = false,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      recipientId: json['recipient_id'],
      message: json['message'],
      relatedProjectId: json['related_project_id'],
      read: json['read'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipient_id': recipientId,
      'message': message,
      'related_project_id': relatedProjectId,
      'read': read,
    };
  }
}
