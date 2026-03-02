class Quote {
  final String id;
  final String clientId;
  final String serviceType;
  final String title;
  final String? description;
  final String phone;
  final String email;
  final String? urgency;
  final String? hasCurrentSystem;
  final String? isReplacement;
  final List<String> documentsUrls;
  final String status;
  final DateTime createdAt;

  Quote({
    required this.id,
    required this.clientId,
    required this.serviceType,
    required this.title,
    this.description,
    required this.phone,
    required this.email,
    this.urgency,
    this.hasCurrentSystem,
    this.isReplacement,
    this.documentsUrls = const [],
    required this.status,
    required this.createdAt,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      serviceType: json['service_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      phone: json['phone'] as String,
      email: json['email'] as String,
      urgency: json['urgency'] as String?,
      hasCurrentSystem: json['has_current_system'] as String?,
      isReplacement: json['is_replacement'] as String?,
      documentsUrls: json['documents_urls'] != null
          ? List<String>.from(json['documents_urls'] as List)
          : [],
      status: json['status'] as String? ?? 'recibida',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'client_id': clientId,
      'service_type': serviceType,
      'title': title,
      'description': description,
      'phone': phone,
      'email': email,
      'urgency': urgency,
      'has_current_system': hasCurrentSystem,
      'is_replacement': isReplacement,
      'documents_urls': documentsUrls,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
