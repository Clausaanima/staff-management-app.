import 'package:personal_expert/models/employee_model.dart';
import 'package:personal_expert/models/skill_model.dart';

class EmployeeSkill {
  final String employeeId;
  final String skillId;
  final String? level;
  final Employee? employee; // Связанный объект
  final Skill? skill; // Связанный объект

  EmployeeSkill({
    required this.employeeId,
    required this.skillId,
    this.level,
    this.employee,
    this.skill,
  });

  factory EmployeeSkill.fromJson(Map<String, dynamic> json) {
    return EmployeeSkill(
      employeeId: json['employee_id'],
      skillId: json['skill_id'],
      level: json['level'],
      employee: json['employee'] != null 
          ? Employee.fromJson(json['employee']) 
          : null,
      skill: json['skill'] != null 
          ? Skill.fromJson(json['skill']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'skill_id': skillId,
      'level': level,
      'employee': employee?.toJson(),
      'skill': skill?.toJson(),
    };
  }
}
