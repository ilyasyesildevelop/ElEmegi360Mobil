import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/app_config.dart';

class UpdateInfo {
  const UpdateInfo({
    required this.latestVersionCode,
    required this.latestVersionName,
    required this.apkUrl,
  });

  final int latestVersionCode;
  final String latestVersionName;
  final String apkUrl;

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersionCode: (json['latestVersionCode'] as num).toInt(),
      latestVersionName: json['latestVersionName'] as String,
      apkUrl: json['apkUrl'] as String,
    );
  }
}

/// Suite Kotlin `UpdateService` ile aynı mantık (GitHub Contents API + base64).
class UpdateService {
  UpdateService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<UpdateInfo> fetchUpdateInfo() async {
    final urls = _candidateUrls(AppConfig.updateInfoUrl);
    Object? lastError;
    for (final url in urls) {
      try {
        final res = await _client.get(
          Uri.parse(url),
          headers: const {
            'Accept': 'application/vnd.github+json',
            'User-Agent': 'Fabrika360-ElEmegi360-UpdateChecker',
          },
        );
        if (res.statusCode != 200) {
          throw Exception('HTTP ${res.statusCode}');
        }
        final info = _parsePayload(res.body);
        if (info.latestVersionCode <= 0 || info.apkUrl.isEmpty) {
          throw Exception('Geçersiz version.json');
        }
        return info;
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('Güncelleme bilgisi alınamadı: $lastError');
  }

  UpdateInfo _parsePayload(String body) {
    try {
      return UpdateInfo.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } catch (_) {
      final gh = jsonDecode(body) as Map<String, dynamic>;
      final content = (gh['content'] as String).replaceAll('\n', '');
      final decoded = utf8.decode(base64.decode(content));
      return UpdateInfo.fromJson(jsonDecode(decoded) as Map<String, dynamic>);
    }
  }

  List<String> _candidateUrls(String primary) {
    return [
      primary,
      primary.replaceFirst('api.github.com/repos/', 'raw.githubusercontent.com/')
          .replaceFirst('/contents/', '/')
          .replaceFirst('?ref=master', ''),
    ];
  }
}
