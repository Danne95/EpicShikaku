import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shikaku_puzzle/app/data/app_update_service.dart';

/// User-visible state for the direct APK update flow.
enum AppUpdateStatus {
  /// No update action has been requested.
  idle,

  /// The app is checking GitHub for the latest release.
  checking,

  /// The installed app is already on the latest release.
  upToDate,

  /// A newer APK release is available.
  updateAvailable,

  /// The APK file is being downloaded.
  downloading,

  /// The APK has downloaded and can be handed to Android's installer.
  readyToInstall,

  /// The last update action failed.
  failed,
}

/// Coordinates user-initiated app update checks and APK installation.
class AppUpdateController extends ChangeNotifier {
  /// Creates an update controller.
  AppUpdateController({required this.service});

  /// Service used for GitHub and Android update operations.
  final AppUpdateService service;

  AppUpdateStatus _status = AppUpdateStatus.idle;
  AppRelease? _availableRelease;
  String? _downloadedApkPath;
  String? _message;
  String? _errorMessage;

  /// Current user-visible update state.
  AppUpdateStatus get status => _status;

  /// Latest release information when an update is available.
  AppRelease? get availableRelease => _availableRelease;

  /// Informational text for the current state.
  String? get message => _message;

  /// Failure text for the last failed update action.
  String? get errorMessage => _errorMessage;

  /// Whether a downloaded APK is ready for the Android installer.
  bool get hasDownloadedApk => _downloadedApkPath != null;

  /// Checks GitHub Releases for a newer direct-download APK.
  Future<void> checkForUpdates() async {
    _availableRelease = null;
    _downloadedApkPath = null;
    _setState(status: AppUpdateStatus.checking);

    try {
      final result = await service.checkForUpdates();
      _availableRelease = result.release;

      if (result.isUpdateAvailable) {
        _setState(status: AppUpdateStatus.updateAvailable);
        return;
      }

      _setState(status: AppUpdateStatus.upToDate);
    } on AppUpdateException catch (error) {
      _setState(status: AppUpdateStatus.failed, errorMessage: error.message);
    } on PlatformException catch (error) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: _platformErrorMessage(error),
      );
    } catch (_) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: 'Could not check for updates.',
      );
    }
  }

  /// Downloads the latest APK to local app cache storage.
  Future<void> downloadUpdate() async {
    final release = _availableRelease;
    if (release == null) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: 'Check for updates before downloading.',
      );
      return;
    }

    _setState(status: AppUpdateStatus.downloading);

    try {
      _downloadedApkPath = await service.downloadReleaseApk(release);
      _setState(
        status: AppUpdateStatus.readyToInstall,
        message: 'Update downloaded. Android will ask you to confirm install.',
      );
    } on AppUpdateException catch (error) {
      _setState(status: AppUpdateStatus.failed, errorMessage: error.message);
    } on PlatformException catch (error) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: _platformErrorMessage(error),
      );
    } catch (_) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: 'Could not download the update.',
      );
    }
  }

  /// Downloads the update if needed and opens Android's installer.
  Future<void> getUpdate() async {
    final release = _availableRelease;
    if (release == null) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: 'Check for updates before updating.',
      );
      return;
    }

    try {
      if (_downloadedApkPath == null) {
        _setState(status: AppUpdateStatus.downloading);
        _downloadedApkPath = await service.downloadReleaseApk(release);
      }

      await _installDownloadedUpdate();
    } on AppUpdateException catch (error) {
      _setState(status: AppUpdateStatus.failed, errorMessage: error.message);
    } on PlatformException catch (error) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: _platformErrorMessage(error),
      );
    } catch (_) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: 'Could not get the update.',
      );
    }
  }

  /// Opens Android's package installer for the downloaded APK.
  Future<void> installDownloadedUpdate() async {
    try {
      await _installDownloadedUpdate();
    } on AppUpdateException catch (error) {
      _setState(status: AppUpdateStatus.failed, errorMessage: error.message);
    } on PlatformException catch (error) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: _platformErrorMessage(error),
      );
    } catch (_) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: 'Could not start the Android installer.',
      );
    }
  }

  Future<void> _installDownloadedUpdate() async {
    final apkPath = _downloadedApkPath;
    if (apkPath == null) {
      _setState(
        status: AppUpdateStatus.failed,
        errorMessage: 'Download the update before installing.',
      );
      return;
    }

    final canInstall = await service.canRequestPackageInstalls();
    if (!canInstall) {
      await service.openInstallPermissionSettings();
      _setState(status: AppUpdateStatus.updateAvailable);
      return;
    }

    await service.installApk(apkPath);
    _setState(status: AppUpdateStatus.updateAvailable);
  }

  void _setState({
    required AppUpdateStatus status,
    String? message,
    String? errorMessage,
  }) {
    _status = status;
    _message = message;
    _errorMessage = errorMessage;
    notifyListeners();
  }

  String _platformErrorMessage(PlatformException error) {
    final message = error.message;
    if (message != null && message.isNotEmpty) {
      return message;
    }

    return switch (error.code) {
      'apk_missing' => 'Downloaded update was not found.',
      'installer_unavailable' => 'Could not open installer.',
      'install_permission_settings_unavailable' =>
        'Could not open install permission settings.',
      'cache_directory_unavailable' => 'Could not prepare the update download.',
      _ => 'Could not get the update.',
    };
  }
}
