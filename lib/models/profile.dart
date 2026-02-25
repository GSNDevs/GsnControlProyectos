class Profile {
  final String id;
  final String? email;
  final String? fullName;
  final String? avatarUrl;
  final String role; // 'admin', 'staff', 'client', 'public'
  final String? rut;
  final String? companyName;
  final String? fantasyName;
  final String? address;
  final bool enabled;
  final DateTime createdAt;

  const Profile({
    required this.id,
    this.email,
    this.fullName,
    this.avatarUrl,
    this.role = 'staff',
    this.rut,
    this.companyName,
    this.fantasyName,
    this.address,
    this.enabled = true,
    required this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'staff',
      rut: json['rut'],
      companyName: json['company_name'],
      fantasyName: json['fantasy_name'],
      address: json['address'],
      enabled: json['enabled'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'role': role,
      'rut': rut,
      'company_name': companyName,
      'fantasy_name': fantasyName,
      'address': address,
      'enabled': enabled,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
