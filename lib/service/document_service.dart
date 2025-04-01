import 'package:personal_expert/models/document_model.dart';
import 'package:personal_expert/service/supabase_service.dart';

class DocumentService extends SupabaseService {
  final String table = 'documents';

  Future<List<Document>> getEmployeeDocuments(String employeeId) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .select('*, employee:employees(*)')
          .eq('employee_id', employeeId)
          .order('upload_date');
      
      return (response as List)
          .map((json) => Document.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch documents: $e');
    }
  }

  Future<Document> createDocument(Document document) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .insert(document.toJson())
          .select('*, employee:employees(*)')
          .single();
      
      return Document.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create document: $e');
    }
  }

  Future<Document> updateDocument(Document document) async {
    try {
      final response = await SupabaseService.supabase
          .from(table)
          .update(document.toJson())
          .eq('id', document.id)
          .select('*, employee:employees(*)')
          .single();
      
      return Document.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update document: $e');
    }
  }

  Future<void> deleteDocument(String id) async {
    try {
      await SupabaseService.supabase
          .from(table)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}