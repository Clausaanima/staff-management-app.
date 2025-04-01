import 'package:personal_expert/models/employee_model.dart';

class Department {
  final String id;
  final String name;
  final String? description;
  final String? managerId;
  final DateTime createdAt;
  final Employee? manager; // Связанный объект

  Department({
    required this.id,
    required this.name,
    this.description,
    this.managerId,
    required this.createdAt,
    this.manager,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      managerId: json['manager_id'],
      createdAt: DateTime.parse(json['created_at']),
      manager: json['manager'] != null 
          ? Employee.fromJson(json['manager']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'manager_id': managerId,
      'created_at': createdAt.toIso8601String(),
      'manager': manager?.toJson(),
    };
  }
}