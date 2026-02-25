enum IterationApprovalStatus { pending, approved, rejected }

class Iteration {
  final String id;
  final String projectId;
  final String name;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final IterationApprovalStatus clientApprovalStatus;
  final DateTime? clientApprovalDate;
  final DateTime? createdAt;

  const Iteration({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.clientApprovalStatus = IterationApprovalStatus.pending,
    this.clientApprovalDate,
    this.createdAt,
  });

  factory Iteration.fromJson(Map<String, dynamic> json) {
    return Iteration(
      id: json['id'],
      projectId: json['project_id'],
      name: json['name'],
      description: json['description'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      clientApprovalStatus: _parseStatus(json['client_approval_status']),
      clientApprovalDate: json['client_approval_date'] != null
          ? DateTime.parse(json['client_approval_date'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'name': name,
      'description': description,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'client_approval_status': clientApprovalStatus.name,
    };
  }

  static IterationApprovalStatus _parseStatus(String? val) {
    return IterationApprovalStatus.values.firstWhere(
      (e) => e.name == val,
      orElse: () => IterationApprovalStatus.pending,
    );
  }
}
