import 'package:personal_expert/models/position.dart';
import 'package:personal_expert/service/supabase_service.dart';

class PositionService extends SupabaseService {
  final String table = 'positions';

  Future<List<Position>> getAllPositions() async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select()
          .order('title');
      
      return (response as List)
          .map((json) => Position.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch positions: $e');
    }
  }

  Future<Position> getPositionById(String id) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select()
          .eq('id', id)
          .single();
      
      return Position.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch position: $e');
    }
  }

  Future<Position> createPosition(Position position) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .insert(position.toJson())
          .select()
          .single();
      
      return Position.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create position: $e');
    }
  }

  Future<Position> updatePosition(Position position) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .update(position.toJson())
          .eq('id', position.id)
          .select()
          .single();
      
      return Position.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update position: $e');
    }
  }

  Future<void> deletePosition(String id) async {
    try {
      await SupabaseService.supabase
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete position: $e');
    }
  }
}