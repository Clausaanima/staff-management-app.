import 'package:personal_expert/models/employee_model.dart';
import 'package:personal_expert/service/supabase_service.dart';

class EmployeeService extends SupabaseService {
  final String table = 'employees';

Future<List<Employee>> getAllEmployees() async {
  try {
    final response = await SupabaseService.supabase
        .from('employees')
        .select('''
          *,
          departments!fk_department (*)
        ''');

    final List<dynamic> data = response as List<dynamic>;
    return data.map((json) => Employee.fromJson(json)).toList();
  } catch (e) {
    throw Exception('Failed to fetch employees: $e');
  }
}

  Future<Employee> getEmployeeById(String id) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select('''
            *,
            department:departments(*),
            position:positions(*),
            manager:employees(*)
          ''')
          .eq('id', id)
          .single();
      
      return Employee.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch employee: $e');
    }
  }

  Future<List<Employee>> getEmployeesByDepartment(String departmentId) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select('''
            *,
            department:departments(*),
            position:positions(*),
            manager:employees(*)
          ''')
          .eq('department_id', departmentId)
          .order('created_at');
      
      return (response as List)
          .map((json) => Employee.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employees by department: $e');
    }
  }

  Future<Employee> createEmployee(Employee employee) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .insert(employee.toJson())
          .select('''
            *,
            department:departments(*),
            position:positions(*),
            manager:employees(*)
          ''')
          .single();
      
      return Employee.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create employee: $e');
    }
  }

  Future<Employee> updateEmployee(Employee employee) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .update(employee.toJson())
          .eq('id', employee.id)
          .select('''
            *,
            department:departments(*),
            position:positions(*),
            manager:employees(*)
          ''')
          .single();
      
      return Employee.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update employee: $e');
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      await SupabaseService.supabase
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }
}