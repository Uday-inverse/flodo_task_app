import 'package:shared_preferences/shared_preferences.dart';

class DraftService {
  Future<void> saveDraft({
    required String title,
    required String description,
    required String dueDate,
    required String status,
    required String blockedBy,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('draft_title', title);
    await prefs.setString('draft_description', description);
    await prefs.setString('draft_due_date', dueDate);
    await prefs.setString('draft_status', status);
    await prefs.setString('draft_blocked_by', blockedBy);
  }

  Future<Map<String, String>> getDraft() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'title': prefs.getString('draft_title') ?? '',
      'description': prefs.getString('draft_description') ?? '',
      'dueDate': prefs.getString('draft_due_date') ?? '',
      'status': prefs.getString('draft_status') ?? 'To-Do',
      'blockedBy': prefs.getString('draft_blocked_by') ?? '',
    };
  }

  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft_title');
    await prefs.remove('draft_description');
    await prefs.remove('draft_due_date');
    await prefs.remove('draft_status');
    await prefs.remove('draft_blocked_by');
  }
}