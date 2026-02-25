class ProjectPayment {
  final String id;
  final String projectId;
  final double amount;
  final String paymentType; // 'unico', 'suscripcion', 'adicional'
  final String? description;
  final DateTime paymentDate;
  final String? createdBy;

  const ProjectPayment({
    required this.id,
    required this.projectId,
    required this.amount,
    required this.paymentType,
    this.description,
    required this.paymentDate,
    this.createdBy,
  });

  factory ProjectPayment.fromJson(Map<String, dynamic> json) {
    return ProjectPayment(
      id: json['id'],
      projectId: json['project_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentType: json['payment_type'],
      description: json['description'],
      paymentDate: DateTime.parse(json['payment_date']),
      createdBy: json['created_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'amount': amount,
      'payment_type': paymentType,
      'description': description,
      // let server default the payment_date if null or provide one
    };
  }
}
