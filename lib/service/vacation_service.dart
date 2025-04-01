import 'package:personal_expert/models/vacation_model.dart';
import 'package:personal_expert/service/supabase_service.dart';

class VacationService extends SupabaseService {
  final String table = 'vacations';

  Future<List<Vacation>> getAllVacations() async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select('*, employee:employees(*)')
          .order('start_date');
      
      return (response as List)
          .map((json) => Vacation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all vacations: $e');
    }
  }

  Future<List<Vacation>> getEmployeeVacations(String employeeId) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select('*, employee:employees(*)')
          .eq('employee_id', employeeId)
          .order('start_date');
      
      return (response as List)
          .map((json) => Vacation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employee vacations: $e');
    }
  }

  Future<Vacation> createVacation(Vacation vacation) async {
    try {
      final Map<String, dynamic> data = vacation.toJson()
        ..remove('id')
        ..remove('employee');

      final response = await SupabaseService.supabase
          .from(table)
          .insert(data)
          .select('*, employee:employees(*)')
          .single();
      
      return Vacation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create vacation: $e');
    }
  }

  Future<Vacation> updateVacation(Vacation vacation) async {
    try {
      final Map<String, dynamic> data = vacation.toJson()
        ..remove('id')
        ..remove('employee');

      final response = await SupabaseService.supabase
          .from(table)
          .update(data)
          .eq('id', vacation.id)
          .select('*, employee:employees(*)')
          .single();
      
      return Vacation.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update vacation: $e');
    }
  }

  Future<void> deleteVacation(String id) async {
    try {
      await SupabaseService.supabase
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete vacation: $e');
    }
  }

  Future<List<Vacation>> getVacationsInPeriod(DateTime startDate, DateTime endDate) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select('*, employee:employees(*)')
          .gte('start_date', startDate.toIso8601String())
          .lte('end_date', endDate.toIso8601String())
          .order('start_date');
      
      return (response as List)
          .map((json) => Vacation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch vacations in period: $e');
    }
  }

  Future<bool> hasVacationOverlap(String employeeId, DateTime startDate, DateTime endDate, [String? excludeVacationId]) async {
    try {
      var query = SupabaseService.supabase
          .from(table)
          .select('id')
          .eq('employee_id', employeeId)
          .or('start_date.lte.${endDate.toIso8601String()},end_date.gte.${startDate.toIso8601String()}');

      if (excludeVacationId != null) {
        query = query.neq('id', excludeVacationId);
      }

      final response = await query;
      
      return (response as List).isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check vacation overlap: $e');
    }
  }
}