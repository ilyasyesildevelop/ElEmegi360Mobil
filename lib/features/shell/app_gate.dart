import 'package:flutter/material.dart';

import '../../data/admin_auth_service.dart';
import '../../data/local/profile_store.dart';
import '../../data/records_store.dart';
import '../../data/remote/app_warmup.dart';
import '../../theme/el_emegi_colors.dart';
import '../onboarding/onboarding_screen.dart';
import 'main_shell.dart';

/// Profil yüklenene / kayıt tamamlanana kadar onboarding veya ana kabuk.
class AppGate extends StatefulWidget {
  const AppGate({super.key});

  @override
  State<AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<AppGate> {
  bool _booting = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Yerel profil + önbellek — ağ beklemeden ana ekran.
  Future<void> _bootstrap() async {
    await Future.wait([
      ProfileStore.instance.load(),
      AdminAuthService.instance.load(),
    ]);

    if (ProfileStore.instance.isRegistered) {
      await RecordsStore.instance.loadFromCache();
    }

    if (mounted) setState(() => _booting = false);

    AppWarmup.runInBackground();
  }

  Future<void> _onOnboardingDone() async {
    await AppWarmup.runInBackground();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_booting) {
      return const Scaffold(
        backgroundColor: ElEmegiColors.darkNavy,
        body: Center(
          child: CircularProgressIndicator(color: ElEmegiColors.teal),
        ),
      );
    }

    return ListenableBuilder(
      listenable: ProfileStore.instance,
      builder: (context, _) {
        if (!ProfileStore.instance.isRegistered) {
          return OnboardingScreen(onComplete: _onOnboardingDone);
        }
        return const MainShell();
      },
    );
  }
}
