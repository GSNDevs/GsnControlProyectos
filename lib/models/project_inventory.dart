class ProjectInventory {
  final String id;
  final String projectId;
  final String productId;
  final int quantity;
  final String? assignedToUserId;
  final String status; // 'reserved', 'installed', 'returned'
  final DateTime? createdAt;

  const ProjectInventory({
    required this.id,
    required this.projectId,
    required this.productId,
    this.quantity = 1,
    this.assignedToUserId,
    this.status = 'reserved',
    this.createdAt,
  });

  factory ProjectInventory.fromJson(Map<String, dynamic> json) {
    return ProjectInventory(
      id: json['id'],
      projectId: json['project_id'],
      productId: json['product_id'],
      quantity: json['quantity'] ?? 1,
      assignedToUserId: json['assigned_to_user_id'],
      status: json['status'] ?? 'reserved',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'product_id': productId,
      'quantity': quantity,
      'assigned_to_user_id': assignedToUserId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
