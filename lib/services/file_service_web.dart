import 'dart:convert';
import 'dart:html';

Future<void> saveProgramFile(String programName, String jsonContent) async {
  final req = await HttpRequest.request(
    '/api/programs',
    method: 'POST',
    sendData: jsonEncode({
      'filename': programName,
      'content': jsonDecode(jsonContent),
    }),
    requestHeaders: {'Content-Type': 'application/json'},
  );
  if (req.status != 200) {
    throw Exception('Save failed: ${req.status} ${req.statusText}');
  }
}

void downloadJsonFile(String filename, String content) {
  final blob = Blob([content], 'application/json');
  final url = Url.createObjectUrlFromBlob(blob);
  AnchorElement(href: url)
    ..setAttribute('download', '$filename.json')
    ..click();
  Url.revokeObjectUrl(url);
}
