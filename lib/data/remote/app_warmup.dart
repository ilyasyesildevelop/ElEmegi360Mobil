import 'package:flutter/foundation.dart';

import '../local/profile_store.dart';
import '../records_store.dart';
import 'firebase_bootstrap.dart';
import 'person_profile_repository.dart';

/// Açılış sonrası arka plan: Firebase, profil senkronu, kayıtlar.
abstract final class AppWarmup {
  static Future<void>? _inFlight;

  /// Tek seferlik; eşzamanlı çağrılar aynı işi paylaşır.
  static Future<void> runInBackground() {
    final running = _inFlight;
    if (running != null) return running;

    final future = _run();
    _inFlight = future;
    return future.whenComplete(() {
      if (identical(_inFlight, future)) _inFlight = null;
    });
  }

  static Future<void> _run() async {
    try {
      await FirebaseBootstrap.ensureReady();

      if (FirebaseBootstrap.isReady) {
        final uid = await FirebaseBootstrap.alignProfileWithAuth();
        if (!ProfileStore.instance.isRegistered && uid != null) {
          final remote = await PersonProfileRepository.tryCreate()?.fetch(uid);
          if (remote != null && remote.locked) {
            await ProfileStore.instance.adoptFromRemote(remote);
          }
        } else if (ProfileStore.instance.isRegistered) {
          final profile = ProfileStore.instance.profile;
          final repo = PersonProfileRepository.tryCreate();
          if (repo != null && profile != null) {
            await repo.touchLastSeen(profile.ownerUid);
          }
        }
      } else if (!ProfileStore.instance.isRegistered) {
        final uid = await FirebaseBootstrap.ensureOwnerUidOrLocal();
        final remote = await PersonProfileRepository.tryCreate()?.fetch(uid);
        if (remote != null && remote.locked) {
          await ProfileStore.instance.adoptFromRemote(remote);
        }
      }

      if (ProfileStore.instance.isRegistered) {
        await RecordsStore.instance.refresh();
      }
    } catch (e, st) {
      debugPrint('AppWarmup: $e\n$st');
    }
  }
}
