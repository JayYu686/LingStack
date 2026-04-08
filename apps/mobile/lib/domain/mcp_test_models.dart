enum McpTestStepState { idle, loading, success, error, unsupported }

class McpTestProfile {
  const McpTestProfile({
    required this.resourceId,
    required this.baseUrl,
    required this.transport,
    required this.bearerToken,
    required this.headers,
    required this.customMethod,
    required this.customParamsJson,
  });

  final String resourceId;
  final String baseUrl;
  final String transport;
  final String bearerToken;
  final Map<String, String> headers;
  final String customMethod;
  final String customParamsJson;

  Map<String, dynamic> toMap() => {
    'resourceId': resourceId,
    'baseUrl': baseUrl,
    'transport': transport,
    'bearerToken': bearerToken,
    'headers': headers,
    'customMethod': customMethod,
    'customParamsJson': customParamsJson,
  };

  factory McpTestProfile.fromMap(Map<String, dynamic> map) {
    return McpTestProfile(
      resourceId: map['resourceId'] as String? ?? '',
      baseUrl: map['baseUrl'] as String? ?? '',
      transport: map['transport'] as String? ?? 'streamable_http',
      bearerToken: map['bearerToken'] as String? ?? '',
      headers: (map['headers'] as Map? ?? const <String, dynamic>{}).map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      ),
      customMethod: map['customMethod'] as String? ?? 'tools/list',
      customParamsJson: map['customParamsJson'] as String? ?? '{}',
    );
  }

  McpTestProfile copyWith({
    String? resourceId,
    String? baseUrl,
    String? transport,
    String? bearerToken,
    Map<String, String>? headers,
    String? customMethod,
    String? customParamsJson,
  }) {
    return McpTestProfile(
      resourceId: resourceId ?? this.resourceId,
      baseUrl: baseUrl ?? this.baseUrl,
      transport: transport ?? this.transport,
      bearerToken: bearerToken ?? this.bearerToken,
      headers: headers ?? this.headers,
      customMethod: customMethod ?? this.customMethod,
      customParamsJson: customParamsJson ?? this.customParamsJson,
    );
  }
}

class McpTestStepResult {
  const McpTestStepResult({
    required this.id,
    required this.title,
    this.state = McpTestStepState.idle,
    this.statusCode,
    this.summary = '',
    this.body = '',
    this.error = '',
  });

  final String id;
  final String title;
  final McpTestStepState state;
  final int? statusCode;
  final String summary;
  final String body;
  final String error;

  McpTestStepResult copyWith({
    String? id,
    String? title,
    McpTestStepState? state,
    int? statusCode,
    String? summary,
    String? body,
    String? error,
  }) {
    return McpTestStepResult(
      id: id ?? this.id,
      title: title ?? this.title,
      state: state ?? this.state,
      statusCode: statusCode ?? this.statusCode,
      summary: summary ?? this.summary,
      body: body ?? this.body,
      error: error ?? this.error,
    );
  }
}

class McpProbeResult {
  const McpProbeResult({
    required this.healthy,
    required this.statusCode,
    this.bodyPreview = '',
    this.capabilities = const <String, dynamic>{},
    this.serverInfo = const <String, dynamic>{},
    this.protocolVersion = '',
    this.error = '',
  });

  final bool healthy;
  final int statusCode;
  final String bodyPreview;
  final Map<String, dynamic> capabilities;
  final Map<String, dynamic> serverInfo;
  final String protocolVersion;
  final String error;

  factory McpProbeResult.fromMap(Map<String, dynamic> map) {
    return McpProbeResult(
      healthy: map['healthy'] as bool? ?? false,
      statusCode: map['statusCode'] as int? ?? 0,
      bodyPreview: map['bodyPreview'] as String? ?? '',
      capabilities: Map<String, dynamic>.from(
        map['capabilities'] as Map? ?? const <String, dynamic>{},
      ),
      serverInfo: Map<String, dynamic>.from(
        map['serverInfo'] as Map? ?? const <String, dynamic>{},
      ),
      protocolVersion: map['protocolVersion'] as String? ?? '',
      error: map['error'] as String? ?? '',
    );
  }
}

class McpInvokeResult {
  const McpInvokeResult({required this.statusCode, this.body, this.error = ''});

  final int statusCode;
  final Object? body;
  final String error;

  factory McpInvokeResult.fromMap(Map<String, dynamic> map) {
    return McpInvokeResult(
      statusCode: map['statusCode'] as int? ?? 0,
      body: map['body'],
      error: map['error'] as String? ?? '',
    );
  }
}
