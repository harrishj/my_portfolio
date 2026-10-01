class ExperienceItem {
  final String id;
  final String type; // 'work' or 'education'
  final String role; // e.g. 'Full-Stack Flutter Engineer' or 'B.Tech — CS'
  final String company; // e.g. 'Wizinoa' or 'Engineering University'
  final String period; // e.g. '2024 — PRESENT' or '2022 — 2026'
  final String description;
  final String location;
  final bool isActive;
  final int orderIndex;

  const ExperienceItem({
    required this.id,
    required this.type,
    required this.role,
    required this.company,
    required this.period,
    required this.description,
    this.location = '',
    this.isActive = true,
    this.orderIndex = 0,
  });

  factory ExperienceItem.fromJson(Map<String, dynamic> json) {
    return ExperienceItem(
      id: json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: json['type']?.toString() ?? 'work',
      role: json['role']?.toString() ?? json['title']?.toString() ?? '',
      company: json['company']?.toString() ?? json['institution']?.toString() ?? '',
      period: json['period']?.toString() ?? json['years']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['isActive'] is bool ? json['isActive'] as bool : true),
      orderIndex: json['order_index'] is int
          ? json['order_index'] as int
          : (json['orderIndex'] is int ? json['orderIndex'] as int : int.tryParse(json['order_index']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'role': role,
      'company': company,
      'period': period,
      'description': description,
      'location': location,
      'is_active': isActive,
      'order_index': orderIndex,
    };
  }

  ExperienceItem copyWith({
    String? id,
    String? type,
    String? role,
    String? company,
    String? period,
    String? description,
    String? location,
    bool? isActive,
    int? orderIndex,
  }) {
    return ExperienceItem(
      id: id ?? this.id,
      type: type ?? this.type,
      role: role ?? this.role,
      company: company ?? this.company,
      period: period ?? this.period,
      description: description ?? this.description,
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
