import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl;

  ApiService() : baseUrl = 'http://${dotenv.env['BASE_URL']}';

  /// GET request
  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request failed: $e');
    }
  }

  /// POST request
  Future<dynamic> post(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.post(
        url,
        headers: _defaultHeaders(headers),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  /// POST with file upload
  Future<dynamic> postWithFile(
    String endpoint, {
    required Map<String, String> fields,
    required File file,
    required String fileFieldName,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);

    // Add text fields
    fields.forEach((key, value) {
      request.fields[key] = value;
    });

    // Add file with explicit MIME type
    final mimeType = _lookupMimeType(file.path);
    final fileStream = await http.MultipartFile.fromPath(
      fileFieldName,
      file.path,
      contentType: MediaType(
        mimeType.split('/')[0],
        mimeType.split('/')[1],
      ),
    );
    request.files.add(fileStream);

    // Add headers if provided
    if (headers != null) {
      request.headers.addAll(headers);
    }

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(responseBody);
      } else {
        throw Exception(
            'HTTP Error: ${response.statusCode}, ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('POST with file failed: $e');
    }
  }

  /// PUT request
  Future<dynamic> put(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.put(
        url,
        headers: _defaultHeaders(headers),
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  /// PATCH request
  Future<dynamic> patch(String endpoint,
      {Map<String, String>? headers, dynamic body}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.patch(
        url,
        headers: _defaultHeaders(headers),
        body: jsonEncode(body),
      );
      print(body);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  Future<void> patchWithFile(String endpoint, {
  required Map<String, String> fields,
  required File file,
  required String fileFieldName,
}) async {
  final uri = Uri.parse('$baseUrl$endpoint');
  final request = http.MultipartRequest('PATCH', uri);

  // Add fields
  fields.forEach((key, value) {
    request.fields[key] = value;
  });
  print(fields);

  // Add file
  final multipartFile = await http.MultipartFile.fromPath(
    fileFieldName,
    file.path,
  );
  request.files.add(multipartFile);

  final response = await request.send();
  if (response.statusCode != 200) {
    throw Exception('Failed to patch: ${response.statusCode}');
  }
}


  /// DELETE request
  Future<dynamic> delete(String endpoint,
      {Map<String, String>? headers}) async {
    final url = Uri.parse('$baseUrl$endpoint');
    try {
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  /// Helper: Handle API response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Successful responses
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return null; // Empty response body
      }
    } else {
      // Error responses
      throw Exception(
          'HTTP Error: ${response.statusCode}, ${response.reasonPhrase}');
    }
  }

  /// Helper: Default headers
  Map<String, String> _defaultHeaders(Map<String, String>? customHeaders) {
    final headers = {
      'Content-Type': 'application/json',
      ...?customHeaders, // Merge custom headers if provided
    };
    return headers;
  }

  String _lookupMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream'; // Fallback for unknown types
    }
  }
}
