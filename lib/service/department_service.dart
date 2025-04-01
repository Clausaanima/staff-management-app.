import 'package:personal_expert/models/department_model.dart';
import 'package:personal_expert/service/supabase_service.dart';

class DepartmentService extends SupabaseService {
  final String table = 'departments';

Future<List<Department>> getAllDepartments() async {
  try {
    final response = await SupabaseService.supabase
        .from('departments')
        .select('''
          *,
          employees!fk_department (*)
        ''');

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Department.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to fetch departments: $e');
  }
}

  Future<Department> getDepartmentById(String id) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select('*, manager:employees(*)')
          .eq('id', id)
          .single();
      
      return Department.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch department: $e');
    }
  }

  Future<Department> createDepartment(Department department) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .insert(department.toJson())
          .select('*, manager:employees(*)')
          .single();
      
      return Department.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create department: $e');
    }
  }

  Future<Department> updateDepartment(Department department) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .update(department.toJson())
          .eq('id', department.id)
          .select('*, manager:employees(*)')
          .single();
      
      return Department.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update department: $e');
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      await SupabaseService.supabase
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete department: $e');
    }
  }
}
