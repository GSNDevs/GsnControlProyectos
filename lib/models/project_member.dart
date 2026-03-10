class ProjectMember {
  final String id;
  final String projectId;
  final String profileId;
  final bool isActive;
  final DateTime createdAt;

  const ProjectMember({
    required this.id,
    required this.projectId,
    required this.profileId,
    this.isActive = true,
    required this.createdAt,
  });

  factory ProjectMember.fromJson(Map<String, dynamic> json) {
    return ProjectMember(
      id: json['id'],
      projectId: json['project_id'],
      profileId: json['profile_id'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'profile_id': profileId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
