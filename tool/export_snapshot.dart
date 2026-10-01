import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  const supabaseUrl = 'https://slwbsiebuoranrtidcxe.supabase.co';
  const anonKey = 'sb_publishable_CCUPPF78NpUnMKSunt-fyw_d19O4uo7';

  final client = HttpClient();

  Future<dynamic> fetchJson(String path) async {
    final uri = Uri.parse('$supabaseUrl$path');
    final request = await client.getUrl(uri);
    request.headers.set('apikey', anonKey);
    request.headers.set('Authorization', 'Bearer $anonKey');
    request.headers.set('Accept', 'application/json');

    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch $path: HTTP ${response.statusCode}');
    }

    final body = await response.transform(utf8.decoder).join();
    return jsonDecode(body);
  }

  try {
    stdout.writeln('Fetching content from Supabase...');
    final content = await fetchJson('/rest/v1/content?select=*');

    stdout.writeln('Fetching projects from Supabase...');
    final projects = await fetchJson('/rest/v1/projects?select=*&order=created_at.asc');

    final snapshot = {
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'content': content,
      'projects': projects,
    };

    final assetsDir = Directory('assets');
    if (!assetsDir.existsSync()) {
      assetsDir.createSync(recursive: true);
    }

    final file = File('assets/content_snapshot.json');
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(snapshot));
    stdout.writeln('Successfully generated ${file.path} (${file.lengthSync()} bytes)');
  } catch (e) {
    stderr.writeln('Error exporting snapshot: $e');
    exit(1);
  } finally {
    client.close();
  }
}
