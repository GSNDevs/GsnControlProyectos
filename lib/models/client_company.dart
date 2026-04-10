class ClientCompany {
  final String id;
  final String name;
  final String? fantasyName;
  final String? rut;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ClientCompany({
    required this.id,
    required this.name,
    this.fantasyName,
    this.rut,
    this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory ClientCompany.fromJson(Map<String, dynamic> json) {
    return ClientCompany(
      id: json['id'],
      name: json['name'],
      fantasyName: json['fantasy_name'],
      rut: json['rut'],
      address: json['address'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'fantasy_name': fantasyName,
      'rut': rut,
      'address': address,
    };
  }
}
