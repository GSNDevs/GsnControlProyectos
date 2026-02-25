class AuditLog {
  final String id;
  final String? userId;
  final String tableName;
  final String? recordId;
  final String? action;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;
  final DateTime? timestamp;

  const AuditLog({
    required this.id,
    this.userId,
    required this.tableName,
    this.recordId,
    this.action,
    this.oldValue,
    this.newValue,
    this.timestamp,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'],
      userId: json['user_id'],
      tableName: json['table_name'],
      recordId: json['record_id'],
      action: json['action'],
      oldValue: json['old_value'],
      newValue: json['new_value'],
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : null,
    );
  }
}
