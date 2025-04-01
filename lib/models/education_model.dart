import 'package:personal_expert/models/employee_model.dart';

class Education {
  final String id;
  final String employeeId;
  final String institution;
  final String? degree;
  final String? fieldOfStudy;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final Employee? employee; // Связанный объект

  Education({
    required this.id,
    required this.employeeId,
    required this.institution,
    this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.employee,
  });

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      id: json['id'],
      employeeId: json['employee_id'],
      institution: json['institution'],
      degree: json['degree'],
      fieldOfStudy: json['field_of_study'],
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      employee: json['employee'] != null 
          ? Employee.fromJson(json['employee']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'institution': institution,
      'degree': degree,
      'field_of_study': fieldOfStudy,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'employee': employee?.toJson(),
    };
  }
}