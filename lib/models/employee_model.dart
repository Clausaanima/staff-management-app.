import 'package:personal_expert/models/department_model.dart';
import 'package:personal_expert/models/position.dart';

class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String email;
  final String? phone;
  final DateTime? birthDate;
  final DateTime hireDate;
  final String? departmentId;
  final String? positionId;
  final double? salary;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Связанные объекты для отображения
  Department? department;
  Position? position;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.email,
    this.phone,
    this.birthDate,
    required this.hireDate,
    this.departmentId,
    this.positionId,
    this.salary,
    this.status = 'active',
    required this.createdAt,
    required this.updatedAt,
    this.department,
    this.position,
  });

  // Полное имя для отображения
  String get fullName => '$lastName $firstName ${middleName ?? ''}'.trim();

  // Преобразование из JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      middleName: json['middle_name'],
      email: json['email'],
      phone: json['phone'],
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : null,
      hireDate: DateTime.parse(json['hire_date']),
      departmentId: json['department_id'],
      positionId: json['position_id'],
      salary: json['salary']?.toDouble(),
      status: json['status'] ?? 'active',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      department: json['department'] != null 
          ? Department.fromJson(json['department']) 
          : null,
      position: json['position'] != null 
          ? Position.fromJson(json['position']) 
          : null,
    );
  }

  // Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'email': email,
      'phone': phone,
      'birth_date': birthDate?.toIso8601String(),
      'hire_date': hireDate.toIso8601String(),
      'department_id': departmentId,
      'position_id': positionId,
      'salary': salary,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}