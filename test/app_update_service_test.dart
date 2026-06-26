import 'package:flutter_test/flutter_test.dart';
import 'package:shikaku_puzzle/app/data/app_update_service.dart';

/// Verifies direct APK update release parsing and version comparison.
void main() {
  test('detects newer semantic versions', () {
    final installed = AppVersion.parse('1.0.0');
    final latest = AppVersion.parse('v1.0.1');

    expect(latest.compareTo(installed), greaterThan(0));
  });

  test('treats equal semantic versions as not newer', () {
    final installed = AppVersion.parse('1.0.0');
    final latest = AppVersion.parse('v1.0.0');

    expect(latest.compareTo(installed), 0);
  });

  test('rejects malformed release versions', () {
    expect(
      () => AppVersion.parse('release-one'),
      throwsA(isA<AppUpdateException>()),
    );
  });

  test('finds the APK asset by display label in latest release JSON', () {
    final service = AppUpdateService();

    final release = service.parseReleaseJson('''
{
  "tag_name": "v1.2.3",
  "body": "New puzzle polish.",
  "assets": [
    {
      "name": "app-release.apk",
      "label": "EpicShikaku.apk",
      "browser_download_url": "https://example.com/app-release.apk"
    }
  ]
}
''');

    expect(release.version.label, '1.2.3');
    expect(
      release.downloadUri.toString(),
      'https://example.com/app-release.apk',
    );
    expect(release.releaseNotes, 'New puzzle polish.');
  });

  test('finds the APK asset by uploaded file name in latest release JSON', () {
    final service = AppUpdateService();

    final release = service.parseReleaseJson('''
{
  "tag_name": "v1.2.3",
  "body": "New puzzle polish.",
  "assets": [
    {
      "name": "EpicShikaku.apk",
      "browser_download_url": "https://example.com/EpicShikaku.apk"
    }
  ]
}
''');

    expect(
      release.downloadUri.toString(),
      'https://example.com/EpicShikaku.apk',
    );
  });

  test('finds the APK asset by default release file name', () {
    final service = AppUpdateService();

    final release = service.parseReleaseJson('''
{
  "tag_name": "v1.2.3",
  "body": "New puzzle polish.",
  "assets": [
    {
      "name": "app-release.apk",
      "browser_download_url": "https://example.com/app-release.apk"
    }
  ]
}
''');

    expect(
      release.downloadUri.toString(),
      'https://example.com/app-release.apk',
    );
  });

  test('fails when the fixed APK asset is missing', () {
    final service = AppUpdateService();

    expect(
      () => service.parseReleaseJson('''
{
  "tag_name": "v1.2.3",
  "assets": []
}
'''),
      throwsA(isA<AppUpdateException>()),
    );
  });

  test('fails when release JSON is invalid', () {
    final service = AppUpdateService();

    expect(
      () => service.parseReleaseJson('not json'),
      throwsA(isA<AppUpdateException>()),
    );
  });
}
