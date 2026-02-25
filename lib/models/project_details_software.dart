class ProjectDetailsSoftware {
  final String projectId;
  final String? repoUrl;
  final String? prodUrl;
  final String? stagingUrl;
  final Map<String, dynamic>? techStack;

  const ProjectDetailsSoftware({
    required this.projectId,
    this.repoUrl,
    this.prodUrl,
    this.stagingUrl,
    this.techStack,
  });

  factory ProjectDetailsSoftware.fromJson(Map<String, dynamic> json) {
    return ProjectDetailsSoftware(
      projectId: json['project_id'],
      repoUrl: json['repo_url'],
      prodUrl: json['prod_url'],
      stagingUrl: json['staging_url'],
      techStack: json['tech_stack'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'repo_url': repoUrl,
      'prod_url': prodUrl,
      'staging_url': stagingUrl,
      'tech_stack': techStack,
    };
  }
}
