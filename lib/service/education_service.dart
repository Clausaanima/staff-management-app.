import 'package:personal_expert/models/education_model.dart';
import 'package:personal_expert/service/supabase_service.dart';

class EducationService extends SupabaseService {
  final String table = 'education';

  Future<List<Education>> getAllEducations() async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select('*, employee:employees(*)')
          .order('start_date');
      
      return (response as List)
          .map((json) => Education.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all education records: $e');
    }
  }

  Future<List<Education>> getEmployeeEducation(String employeeId) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select('*, employee:employees(*)')
          .eq('employee_id', employeeId)
          .order('start_date');
      
      return (response as List)
          .map((json) => Education.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employee education: $e');
    }
  }

  Future<Education> createEducation(Education education) async {
    try {
      // Удаляем поля, которые не должны быть в запросе на создание
      final educationJson = education.toJson()
        ..remove('id')
        ..remove('created_at')
        ..remove('employee');

      final response = await SupabaseService.supabase
          .from(table)
          .insert(educationJson)
          .select('*, employee:employees(*)')
          .single();
      
      return Education.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create education: $e');
    }
  }

  Future<Education> updateEducation(Education education) async {
    try {
      // Удаляем поля, которые не должны быть в запросе на обновление
      final educationJson = education.toJson()
        ..remove('created_at')
        ..remove('employee');

      final response = await SupabaseService.supabase
          .from(table)
          .update(educationJson)
          .eq('id', education.id)
          .select('*, employee:employees(*)')
          .single();
      
      return Education.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update education: $e');
    }
  }

  Future<void> deleteEducation(String id) async {
    try {
      await SupabaseService.supabase
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete education: $e');
    }
  }
}