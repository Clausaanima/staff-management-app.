import 'package:personal_expert/models/skill_model.dart';
import 'package:personal_expert/service/supabase_service.dart';

class SkillService extends SupabaseService {
  final String table = 'skills';

  Future<List<Skill>> getAllSkills() async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select();
      
      return (response as List)
          .map((json) => Skill.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch skills: $e');
    }
  }

  Future<List<Skill>> getEmployeeSkills(String employeeId) async {
    try {
      final response = await SupabaseService.supabase
          .from('employee_skills')
          .select('*, skill:skills(*)')
          .eq('employee_id', employeeId);
      
      return (response as List)
          .map((json) => Skill.fromJson(json['skill']))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employee skills: $e');
    }
  }

  Future<Skill> createSkill(Skill skill) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .insert(skill.toJson())
          .select()
          .single();
      
      return Skill.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create skill: $e');
    }
  }

  Future<Skill> updateSkill(Skill skill) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .update(skill.toJson())
          .eq('id', skill.id)
          .select()
          .single();
      
      return Skill.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update skill: $e');
    }
  }

  Future<void> deleteSkill(String id) async {
    try {
      await SupabaseService.supabase
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete skill: $e');
    }
  }
}
