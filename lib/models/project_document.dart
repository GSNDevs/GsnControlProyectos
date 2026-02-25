class ProjectDocument {
  final String id;
  final String projectId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final String? uploadedBy;
  final DateTime createdAt;

  const ProjectDocument({
    required this.id,
    required this.projectId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    this.uploadedBy,
    required this.createdAt,
  });

  factory ProjectDocument.fromJson(Map<String, dynamic> json) {
    return ProjectDocument(
      id: json['id'],
      projectId: json['project_id'],
      fileName: json['file_name'],
      fileUrl: json['file_url'],
      fileType: json['file_type'],
      uploadedBy: json['uploaded_by'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'project_id': projectId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'uploaded_by': uploadedBy,
      // No mandamos created_at, la db lo genera
    };
  }
}
