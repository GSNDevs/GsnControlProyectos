class ProjectDetailsPhysical {
  final String projectId;
  final String? address;
  final String? coordinates;
  final String? vehicleId;
  final String? installationNotes;

  const ProjectDetailsPhysical({
    required this.projectId,
    this.address,
    this.coordinates,
    this.vehicleId,
    this.installationNotes,
  });

  factory ProjectDetailsPhysical.fromJson(Map<String, dynamic> json) {
    return ProjectDetailsPhysical(
      projectId: json['project_id'],
      address: json['address'],
      coordinates: json['coordinates'],
      vehicleId: json['vehicle_id'],
      installationNotes: json['installation_notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'address': address,
      'coordinates': coordinates,
      'vehicle_id': vehicleId,
      'installation_notes': installationNotes,
    };
  }
}
