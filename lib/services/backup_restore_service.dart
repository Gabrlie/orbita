import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orbita/models/backup_models.dart';
import 'package:orbita/services/backup_encryption_service.dart';
import 'package:orbita/services/backup_snapshot_service.dart';

class BackupRestoreService {
  final BackupEncryptionService encryption;

  const BackupRestoreService({required this.encryption});

  Future<void> restoreWithPassword(
    Ref ref,
    String envelope,
    String password,
  ) async {
    final snapshot = await _decryptSnapshot(
      () => encryption.decryptWithPassword(envelope, password),
    );
    await _restoreSnapshot(ref, snapshot);
  }

  Future<void> restoreWithSecret(
    Ref ref,
    String envelope,
    BackupAutoSecret secret,
  ) async {
    final snapshot = await _decryptSnapshot(
      () => encryption.decryptWithSecret(envelope, secret),
    );
    await _restoreSnapshot(ref, snapshot);
  }

  Future<bool> tryRestoreWithPassword(
    Ref ref,
    String envelope,
    String password,
  ) async {
    try {
      await restoreWithPassword(ref, envelope, password);
      return true;
    } on BackupException catch (error) {
      if (error.message == BackupException.invalidPassword) return false;
      rethrow;
    }
  }

  Future<bool> tryRestoreWithSecret(
    Ref ref,
    String envelope,
    BackupAutoSecret secret,
  ) async {
    try {
      await restoreWithSecret(ref, envelope, secret);
      return true;
    } on BackupException catch (error) {
      if (error.message == BackupException.invalidPassword) return false;
      rethrow;
    }
  }

  Future<Map<String, Object?>> _decryptSnapshot(
    FutureOr<Map<String, Object?>> Function() decrypt,
  ) async {
    try {
      return await decrypt();
    } on FormatException {
      throw const BackupException(BackupException.invalidSnapshot);
    } catch (_) {
      throw const BackupException(BackupException.invalidPassword);
    }
  }

  Future<void> _restoreSnapshot(Ref ref, Map<String, Object?> snapshot) async {
    try {
      await restoreBackupSnapshot(ref, snapshot);
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException(BackupException.invalidSnapshot);
    }
  }
}
