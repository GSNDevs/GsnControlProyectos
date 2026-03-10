class UserDocument {
  final String id;
  final String profileId;
  final String documentType;
  final String fileUrl;
  final DateTime? validUntil;
  final bool isVisibleToClient;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserDocument({
    required this.id,
    required this.profileId,
    required this.documentType,
    required this.fileUrl,
    this.validUntil,
    this.isVisibleToClient = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserDocument.fromJson(Map<String, dynamic> json) {
    return UserDocument(
      id: json['id'],
      profileId: json['profile_id'],
      documentType: json['document_type'],
      fileUrl: json['file_url'],
      validUntil: json['valid_until'] != null ? DateTime.parse(json['valid_until']) : null,
      isVisibleToClient: json['is_visible_to_client'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'document_type': documentType,
      'file_url': fileUrl,
      'valid_until': validUntil?.toIso8601String(),
      'is_visible_to_client': isVisibleToClient,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
