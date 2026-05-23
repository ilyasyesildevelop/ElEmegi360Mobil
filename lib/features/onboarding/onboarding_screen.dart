import 'package:flutter/material.dart';

import '../../core/turkish_text.dart';
import '../../data/local/profile_store.dart';
import '../../data/remote/person_profile_repository.dart';
import '../../data/remote/firebase_bootstrap.dart';
import '../../core/app_meta.dart';
import '../../theme/el_emegi_colors.dart';
import '../../widgets/el_emegi_brand_header.dart';
import '../../widgets/fabrika_gradient_button.dart';
import '../../widgets/premium_glow_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final Future<void> Function() onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  String get _preview =>
      TurkishText.toUpperCase(_controller.text).isEmpty
          ? '—'
          : TurkishText.toUpperCase(_controller.text);

  Future<void> _submit() async {
    final raw = _controller.text.trim();
    final upper = TurkishText.toUpperCase(raw);
    if (upper.length < 3) {
      setState(() => _error = 'Lütfen ad ve soyadınızı girin (en az 3 karakter).');
      return;
    }
    if (!upper.contains(' ')) {
      setState(() => _error = 'Ad ve soyadı birlikte yazın (ör. AYŞE YILMAZ).');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final uid = await FirebaseBootstrap.ensureOwnerUid();
      final profile = await ProfileStore.instance.register(
        ownerUid: uid,
        rawAdSoyad: raw,
      );

      final repo = PersonProfileRepository.tryCreate();
      if (repo != null) {
        await repo.registerPerson(
          profile: profile,
          platform: 'android',
          appVersion: AppMeta.displayVersion,
        );
      }

      if (!mounted) return;
      await widget.onComplete();
    } on ArgumentError catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      final msg = e is StateError && e.message.contains('Anonymous')
          ? 'Firebase oturumu açılamadı. Anonymous Auth etkin olmalı.'
          : 'Kayıt oluşturulamadı. Tekrar deneyin.';
      setState(() => _error = msg);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ElEmegiColors.darkNavy : const Color(0xFFF4F6FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ElEmegiBrandHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Bu telefondan yapılacak tüm kayıtlar aşağıdaki ad soyad ile ilişkilendirilir. '
                  'Onayladıktan sonra değiştirilemez.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: isDark
                            ? ElEmegiColors.threadCream.withValues(alpha: 0.85)
                            : ElEmegiColors.deepNavy.withValues(alpha: 0.8),
                      ),
                ),
                const SizedBox(height: 20),
                Text(
                  'AD SOYAD',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        color: ElEmegiColors.softBlueGray,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Türkçe karakter kullanın (İ, Ş, Ğ, Ü, Ö, Ç).',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: ElEmegiColors.olive,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  focusNode: _focus,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.none,
                  autocorrect: false,
                  enableSuggestions: false,
                  enabled: !_busy,
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Ad Soyad',
                    errorText: _error,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.check_circle_outline, color: ElEmegiColors.teal),
                      onPressed: _busy ? null : _submit,
                    ),
                  ),
                  onChanged: (_) => setState(() => _error = null),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 12),
                PremiumGlowCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kayıtlarda görünecek',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: ElEmegiColors.softBlueGray,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _preview,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: ElEmegiColors.teal,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                FabrikaGradientButton(
                  label: 'Onayla ve kilitle',
                  icon: Icons.lock_outline,
                  loading: _busy,
                  onPressed: _busy ? null : _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
