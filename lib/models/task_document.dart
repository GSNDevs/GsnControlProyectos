class TaskDocument {
  final String id;
  final String taskId;
  final String fileName;
  final String fileUrl;
  final String? uploadedBy;
  final DateTime createdAt;

  const TaskDocument({
    required this.id,
    required this.taskId,
    required this.fileName,
    required this.fileUrl,
    this.uploadedBy,
    required this.createdAt,
  });

  factory TaskDocument.fromJson(Map<String, dynamic> json) {
    return TaskDocument(
      id: json['id'],
      taskId: json['task_id'],
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      uploadedBy: json['uploaded_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_id': taskId,
      'file_name': fileName,
      'file_url': fileUrl,
      'uploaded_by': uploadedBy,
    };
  }
}
