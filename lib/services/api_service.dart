import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../consts/api_constants.dart';
import '../models/api_response.dart';

class ApiService {
  static Future<ApiResponse<dynamic>> get({
    required String endpoint,
    String? token,
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final headers = token != null
          ? ApiConstants.headersWithToken(token)
          : ApiConstants.headers;

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } on TimeoutException {
      return ApiResponse.error(
        'Timeout',
        message: 'Server is taking too long to respond.',
      );
    } on SocketException {
      return ApiResponse.error(
        'Network error',
        message: 'Unable to reach server. Please try again.',
      );
    } catch (e) {
      return ApiResponse.error(
        e.toString(),
        message: 'An unexpected error occurred',
      );
    }
  }

  static Future<ApiResponse<dynamic>> post({
    required String endpoint,
    Map<String, dynamic>? body,
    String? token,
  }) async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      final headers = token != null
          ? ApiConstants.headersWithToken(token)
          : ApiConstants.headers;

      print('🌐 API POST Request:');
      print('URL: $uri');
      print('Headers: $headers');
      print('Body: $body');

      final response = await http.post(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      print('📥 API Response:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      return _handleResponse(response);
    } on SocketException {
      print('❌ Network Error: No Internet Connection');
      return ApiResponse.error(
        'No Internet Connection',
        message: 'Please check your internet connection',
      );
    } catch (e) {
      print('❌ API Error: $e');
      return ApiResponse.error(e.toString(), message: 'An error occurred');
    }
  }

  static Future<ApiResponse<dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    Map<String, File>? files,
    String? token,
  }) async {
    try {
      final uri = Uri.parse(ApiConstants.baseUrl + endpoint);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      if (token != null) {
        request.headers.addAll(ApiConstants.multipartHeadersWithToken(token));
      } else {
        request.headers.addAll({'Accept': 'application/json'});
      }

      // Add fields
      request.fields.addAll(fields);

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          final file = await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
          );
          request.files.add(file);
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(response);
    } on SocketException {
      return ApiResponse.error(
        'No Internet Connection',
        message: 'Please check your internet connection',
      );
    } catch (e) {
      return ApiResponse.error(e.toString(), message: 'An error occurred');
    }
  }

  static ApiResponse<dynamic> _handleResponse(http.Response response) {
    try {
      final decodedBody = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          decodedBody,
          message: _extractMessage(decodedBody),
        );
      } else {
        return ApiResponse.error(
          decodedBody,
          message: _extractMessage(decodedBody),
        );
      }
    } catch (e) {
      return ApiResponse.error(
        response.body,
        message: 'Failed to parse response',
      );
    }
  }

  /// Extract message from API response (handles arrays and objects)
  static String _extractMessage(dynamic body) {
    if (body == null) return 'No message';

    try {
      // If body is a Map
      if (body is Map<String, dynamic>) {
        final message = body['message'];

        // If message is a List (array)
        if (message is List && message.isNotEmpty) {
          // Join all messages with newlines
          return message.map((m) => m.toString()).join('\n');
        }

        // If message is a Map (validation errors)
        if (message is Map) {
          final errors = <String>[];
          message.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.map((v) => v.toString()));
            } else {
              errors.add(value.toString());
            }
          });
          return errors.join('\n');
        }

        // If message is a String
        if (message is String && message.isNotEmpty) {
          return message;
        }

        // Fallback to error field if message is not available
        if (body['error'] != null) {
          return body['error'].toString();
        }
      }

      return 'Request failed';
    } catch (e) {
      return 'Request failed';
    }
  }
}
