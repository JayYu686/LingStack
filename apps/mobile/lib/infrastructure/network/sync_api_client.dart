import 'dart:io';

import 'package:dio/dio.dart';

import '../database/catalog_seed_types.dart';

class SyncApiClient {
  SyncApiClient({Dio? dio, String? baseUrl})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? _defaultBaseUrl(),
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  final Dio _dio;

  static String _defaultBaseUrl() {
    const configured = String.fromEnvironment('SYNC_API_BASE_URL');
    if (configured.isNotEmpty) {
      return configured;
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://127.0.0.1:8080';
  }

  Future<OfficialCatalogSeed> fetchCatalogBootstrap() async {
    final response = await _dio.get<Map<String, dynamic>>('/v1/catalog/bootstrap');
    return OfficialCatalogSeed.fromMap(response.data ?? const {});
  }

  Future<List<Map<String, dynamic>>> fetchCatalogResources({
    String? type,
    String query = '',
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/catalog/resources',
      queryParameters: {
        if (type != null && type.isNotEmpty) 'type': type,
        if (query.trim().isNotEmpty) 'query': query.trim(),
      },
    );
    return (response.data?['resources'] as List<dynamic>? ?? const [])
        .map((value) => Map<String, dynamic>.from(value as Map))
        .toList();
  }

  Future<Map<String, dynamic>> pushChanges(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/sync/push',
      data: payload,
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> pullChanges(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/sync/pull',
      data: payload,
    );
    return response.data ?? const {};
  }

  Future<Map<String, dynamic>> probeMcp(Map<String, dynamic> payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/mcp/probe',
      data: payload,
    );
    return response.data ?? const {};
  }
}
