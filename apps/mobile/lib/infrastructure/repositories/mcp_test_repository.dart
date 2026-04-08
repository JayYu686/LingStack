import 'dart:convert';

import '../../domain/mcp_test_models.dart';
import '../network/sync_api_client.dart';
import '../security/secure_secret_store.dart';

class McpTestRepository {
  const McpTestRepository(this._client, this._secretStore);

  final SyncApiClient _client;
  final SecureSecretStore _secretStore;

  Future<McpTestProfile> loadProfile({
    required String resourceId,
    required String fallbackBaseUrl,
    required String fallbackTransport,
  }) async {
    final stored = await _secretStore.readSecret(_profileKey(resourceId));
    if (stored == null || stored.trim().isEmpty) {
      return McpTestProfile(
        resourceId: resourceId,
        baseUrl: fallbackBaseUrl,
        transport: fallbackTransport,
        bearerToken: '',
        headers: const {},
        customMethod: 'tools/list',
        customParamsJson: '{}',
      );
    }
    final decoded = jsonDecode(stored) as Map<String, dynamic>;
    return McpTestProfile.fromMap(decoded).copyWith(
      resourceId: resourceId,
      baseUrl: decoded['baseUrl'] as String? ?? fallbackBaseUrl,
      transport: decoded['transport'] as String? ?? fallbackTransport,
    );
  }

  Future<void> saveProfile(McpTestProfile profile) {
    return _secretStore.writeSecret(
      _profileKey(profile.resourceId),
      jsonEncode(profile.toMap()),
    );
  }

  Future<McpProbeResult> probe(McpTestProfile profile) {
    return _client.probeMcp(_probePayload(profile));
  }

  Future<McpInvokeResult> invoke({
    required McpTestProfile profile,
    required String method,
    required String paramsJson,
  }) async {
    final params = jsonDecode(paramsJson) as Object?;
    final payload = _probePayload(profile)
      ..addAll({
        'method': method.trim(),
        'params': params ?? const <String, dynamic>{},
      });
    return _client.invokeMcpTest(payload);
  }

  Map<String, dynamic> _probePayload(McpTestProfile profile) => {
    'baseUrl': profile.baseUrl.trim(),
    'transport': profile.transport.trim().isEmpty
        ? 'streamable_http'
        : profile.transport.trim(),
    'bearerToken': profile.bearerToken.trim(),
    'headers': _cleanHeaders(profile.headers),
  };

  Map<String, String> _cleanHeaders(Map<String, String> headers) {
    final cleaned = <String, String>{};
    headers.forEach((key, value) {
      final normalizedKey = key.trim();
      final normalizedValue = value.trim();
      if (normalizedKey.isEmpty || normalizedValue.isEmpty) {
        return;
      }
      cleaned[normalizedKey] = normalizedValue;
    });
    return cleaned;
  }

  String _profileKey(String resourceId) => 'mcp-test-profile::$resourceId';
}
