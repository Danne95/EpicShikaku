import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shikaku_puzzle/app/application/app_update_controller.dart';
import 'package:shikaku_puzzle/app/data/app_update_service.dart';

/// Verifies app update controller install handoff behavior.
void main() {
  test(
    'opens install permission settings when permission is disabled',
    () async {
      final service = _FakeAppUpdateService(canInstallPackages: false);
      final controller = AppUpdateController(service: service);

      await controller.checkForUpdates();
      await controller.getUpdate();

      expect(controller.status, AppUpdateStatus.updateAvailable);
      expect(controller.errorMessage, isNull);
      expect(service.didDownloadApk, isTrue);
      expect(service.didOpenInstallPermissionSettings, isTrue);
      expect(service.didInstallApk, isFalse);
    },
  );

  test('opens installer when install permission is enabled', () async {
    final service = _FakeAppUpdateService(canInstallPackages: true);
    final controller = AppUpdateController(service: service);

    await controller.checkForUpdates();
    await controller.getUpdate();

    expect(controller.status, AppUpdateStatus.updateAvailable);
    expect(controller.errorMessage, isNull);
    expect(service.didDownloadApk, isTrue);
    expect(service.didOpenInstallPermissionSettings, isFalse);
    expect(service.didInstallApk, isTrue);
  });

  test('shows platform install failure message', () async {
    final service = _FakeAppUpdateService(
      canInstallPackages: true,
      installError: PlatformException(
        code: 'installer_unavailable',
        message: 'Could not open installer.',
      ),
    );
    final controller = AppUpdateController(service: service);

    await controller.checkForUpdates();
    await controller.getUpdate();

    expect(controller.status, AppUpdateStatus.failed);
    expect(controller.errorMessage, 'Could not open installer.');
    expect(service.didDownloadApk, isTrue);
    expect(service.didInstallApk, isTrue);
  });
}

class _FakeAppUpdateService extends AppUpdateService {
  _FakeAppUpdateService({required this.canInstallPackages, this.installError});

  final bool canInstallPackages;
  final PlatformException? installError;
  var didDownloadApk = false;
  var didOpenInstallPermissionSettings = false;
  var didInstallApk = false;

  @override
  Future<AppUpdateCheckResult> checkForUpdates() async {
    return AppUpdateCheckResult(
      isUpdateAvailable: true,
      release: AppRelease(
        version: AppVersion.parse('v1.1.2'),
        downloadUri: Uri.parse('https://example.com/EpicShikaku.apk'),
        releaseNotes: 'Update improvements.',
      ),
    );
  }

  @override
  Future<String> downloadReleaseApk(AppRelease release) async {
    didDownloadApk = true;
    return '/cache/updates/EpicShikaku.apk';
  }

  @override
  Future<bool> canRequestPackageInstalls() async {
    return canInstallPackages;
  }

  @override
  Future<void> openInstallPermissionSettings() async {
    didOpenInstallPermissionSettings = true;
  }

  @override
  Future<void> installApk(String apkPath) async {
    didInstallApk = true;
    final installError = this.installError;
    if (installError != null) {
      throw installError;
    }
  }
}
