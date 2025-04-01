import 'package:personal_expert/models/employee_model.dart';

class Document {
  final String id;
  final String employeeId;
  final String type;
  final String title;
  final String? filePath;
  final DateTime uploadDate;
  final Employee? employee; // Связанный объект

  Document({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    this.filePath,
    required this.uploadDate,
    this.employee,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      employeeId: json['employee_id'],
      type: json['type'],
      title: json['title'],
      filePath: json['file_path'],
      uploadDate: DateTime.parse(json['upload_date']),
      employee: json['employee'] != null 
          ? Employee.fromJson(json['employee']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'type': type,
      'title': title,
      'file_path': filePath,
      'upload_date': uploadDate.toIso8601String(),
      'employee': employee?.toJson(),
    };
  }
}