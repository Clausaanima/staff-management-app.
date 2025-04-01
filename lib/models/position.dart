class Position {
  final String id;
  final String title;
  final String? description;
  final double? salaryMin;
  final double? salaryMax;
  final DateTime createdAt;

  Position({
    required this.id,
    required this.title,
    this.description,
    this.salaryMin,
    this.salaryMax,
    required this.createdAt,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      salaryMin: json['salary_min']?.toDouble(),
      salaryMax: json['salary_max']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'salary_min': salaryMin,
      'salary_max': salaryMax,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Диапазон зарплаты для отображения
  String? get salaryRange {
    if (salaryMin == null && salaryMax == null) return null;
    if (salaryMin == null) return 'до $salaryMax';
    if (salaryMax == null) return 'от $salaryMin';
    return '$salaryMin - $salaryMax';
  }
}