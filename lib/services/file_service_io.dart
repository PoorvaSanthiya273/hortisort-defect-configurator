import 'dart:io';

Future<void> saveProgramFile(String programName, String jsonContent) async {
  final dir = Directory('programs');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  final file = File('${dir.path}/$programName.json');
  await file.writeAsString(jsonContent);
}

void downloadJsonFile(String filename, String content) {
  final dir = Directory('exports');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  File('${dir.path}/$filename.json').writeAsStringSync(content);
}
