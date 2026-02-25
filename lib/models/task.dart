enum TaskStatus { todo, doing, done }

class Task {
  final String id;
  final String iterationId;
  final String title;
  final String? description;
  final List<String> assignedTo; // Profile IDs
  final TaskStatus status;
  final String? evidenceUrl;
  final DateTime? createdAt;

  const Task({
    required this.id,
    required this.iterationId,
    required this.title,
    this.description,
    this.assignedTo = const [],
    this.status = TaskStatus.todo,
    this.evidenceUrl,
    this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      iterationId: json['iteration_id'],
      title: json['title'],
      description: json['description'],
      assignedTo: json['assigned_to'] != null
          ? List<String>.from(json['assigned_to'])
          : [],
      status: _parseStatus(json['status']),
      evidenceUrl: json['evidence_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iteration_id': iterationId,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'status': status.name,
      'evidence_url': evidenceUrl,
    };
  }

  static TaskStatus _parseStatus(String? val) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == val,
      orElse: () => TaskStatus.todo,
    );
  }
}
