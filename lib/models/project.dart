import 'package:gsn_control_de_proyectos/models/project_details_physical.dart';
import 'package:gsn_control_de_proyectos/models/project_details_software.dart';

enum ProjectType { physical, software, hybrid }

enum ProjectStatus { planning, in_progress, blocked, completed }

class Project {
  final String id;
  final String name;
  final String? clientId;
  final ProjectType type;
  final ProjectStatus status;
  final String? description;
  final double budgetTotal;
  final double billedAmount;
  final double pendingAmount;
  final String currency;
  final int progress;
  final bool isTemplate;
  final String? driveFolderUrl;
  final String? reportsDriveUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional joined details
  final ProjectDetailsPhysical? detailsPhysical;
  final ProjectDetailsSoftware? detailsSoftware;

  const Project({
    required this.id,
    required this.name,
    this.clientId,
    required this.type,
    required this.status,
    this.description,
    this.budgetTotal = 0.0,
    this.billedAmount = 0.0,
    this.pendingAmount = 0.0,
    this.currency = 'CLP',
    this.progress = 0,
    this.isTemplate = false,
    this.driveFolderUrl,
    this.reportsDriveUrl,
    this.createdAt,
    this.updatedAt,
    this.detailsPhysical,
    this.detailsSoftware,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      name: json['name'],
      clientId: json['client_id'],
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      description: json['description'],
      budgetTotal: (json['budget_total'] as num?)?.toDouble() ?? 0.0,
      billedAmount: (json['billed_amount'] as num?)?.toDouble() ?? 0.0,
      pendingAmount: (json['pending_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'CLP',
      progress: json['progress'] ?? 0,
      isTemplate: json['is_template'] ?? false,
      driveFolderUrl: json['drive_folder_url'],
      reportsDriveUrl: json['reports_drive_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      detailsPhysical: json['project_details_physical'] != null
          ? ProjectDetailsPhysical.fromJson(json['project_details_physical'])
          : null,
      detailsSoftware: json['project_details_software'] != null
          ? ProjectDetailsSoftware.fromJson(json['project_details_software'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'client_id': clientId,
      'type': type.name, // 'physical', 'software', 'hybrid'
      'status': status.name,
      'description': description,
      'budget_total': budgetTotal,
      'billed_amount': billedAmount,
      'pending_amount': pendingAmount,
      'currency': currency,
      'progress': progress,
      'is_template': isTemplate,
      'drive_folder_url': driveFolderUrl,
      'reports_drive_url': reportsDriveUrl,
    };
  }

  static ProjectType _parseType(String? val) {
    return ProjectType.values.firstWhere(
      (e) => e.name == val,
      orElse: () => ProjectType.physical,
    );
  }

  static ProjectStatus _parseStatus(String? val) {
    // Handle camelCase to snake_case if needed or direct match
    // DB has snake_case: 'in_progress'
    // Enum has snake_case: ProjectStatus.in_progress
    return ProjectStatus.values.firstWhere(
      (e) => e.name == val,
      orElse: () => ProjectStatus.planning,
    );
  }
}
