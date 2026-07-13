import 'dart:convert';
import 'dart:html';

class ApiClient {
  static String get _apiBase {
    if (window.location.port == '8081' || window.location.port == '8080') {
      return 'http://localhost:8082';
    }
    return '';
  }

  static Future<Map<String, dynamic>> fetchConfig() async {
    final req = await HttpRequest.request('$_apiBase/api/config');
    if (req.status != 200) throw Exception('Failed to load config');
    return jsonDecode(req.responseText!) as Map<String, dynamic>;
  }

  static Future<List<String>> fetchPrograms() async {
    final req = await HttpRequest.request('$_apiBase/api/programs');
    if (req.status != 200) return [];
    final raw = jsonDecode(req.responseText!);
    if (raw is List && raw.isNotEmpty && raw[0] is String) {
      return raw.cast<String>();
    }
    return (raw as List).map((e) => (e as Map)['name'] as String).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchProgramSummaries() async {
    final req = await HttpRequest.request('$_apiBase/api/programs');
    if (req.status != 200) return [];
    final raw = jsonDecode(req.responseText!);
    if (raw is List && raw.isNotEmpty && raw[0] is Map) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }

  static Future<void> saveProgram(
      String name, Map<String, dynamic> content) async {
    final req = await HttpRequest.request(
      '$_apiBase/api/programs',
      method: 'POST',
      sendData: jsonEncode({'filename': name, 'content': content}),
      requestHeaders: {'Content-Type': 'application/json'},
    );
    if (req.status != 200) throw Exception('Save failed');
  }

  static Future<Map<String, dynamic>?> loadProgram(String name) async {
    final req = await HttpRequest.request('$_apiBase/api/programs/$name');
    if (req.status == 404) return null;
    if (req.status != 200) throw Exception('Load failed');
    return jsonDecode(req.responseText!) as Map<String, dynamic>;
  }

  static Future<void> deleteProgram(String name) async {
    final req = await HttpRequest.request('$_apiBase/api/programs/$name',
        method: 'DELETE');
    if (req.status != 200) throw Exception('Delete failed');
  }
}
