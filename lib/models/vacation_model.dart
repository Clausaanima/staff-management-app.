import 'package:personal_expert/models/employee_model.dart';

class Vacation {
  final String id;
  final String employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String type;
  final String status;
  final DateTime createdAt;
  final Employee? employee; // Связанный объект

  Vacation({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.status,
    required this.createdAt,
    this.employee,
  });

  factory Vacation.fromJson(Map<String, dynamic> json) {
    return Vacation(
      id: json['id'],
      employeeId: json['employee_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      type: json['type'],
      status: json['status'],
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
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'type': type,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'employee': employee?.toJson(),
    };
  }
}