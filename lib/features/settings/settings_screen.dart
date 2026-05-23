import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_config.dart';
import '../../core/app_meta.dart';
import '../../data/local/profile_store.dart';
import '../../data/remote/person_profile_repository.dart';
import '../../data/remote/update_service.dart';
import '../../theme/el_emegi_colors.dart';
import '../../widgets/fabrika_form_card.dart';
import '../../widgets/fabrika_gradient_button.dart';
import '../../widgets/fabrika_section_title.dart';
import '../about/about_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../pricing/unit_prices_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _ibanController;
  bool _ibanSaved = false;
  bool _notificationsEnabled = false;
  bool _checkingUpdate = false;
  String? _updateStatus;

  static const _tileDensity = VisualDensity(horizontal: -2, vertical: -3);

  @override
  void initState() {
    super.initState();
    _ibanController = TextEditingController(text: ProfileStore.instance.iban);
    _notificationsEnabled = ProfileStore.instance.notificationsEnabled;
  }

  @override
  void dispose() {
    _ibanController.dispose();
    super.dispose();
  }

  Future<void> _saveIban() async {
    final value = _ibanController.text.trim();
    await ProfileStore.instance.saveIban(value);
    final profile = ProfileStore.instance.profile;
    final repo = PersonProfileRepository.tryCreate();
    if (repo != null && profile != null && value.isNotEmpty) {
      try {
        await repo.updateIban(profile.ownerUid, value, profile);
      } catch (_) {}
    }
    if (mounted) {
      setState(() => _ibanSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('IBAN kaydedildi')),
      );
    }
  }

  Future<void> _checkForUpdate() async {
    setState(() {
      _checkingUpdate = true;
      _updateStatus = null;
    });
    try {
      final info = await UpdateService().fetchUpdateInfo();
      final pkg = await PackageInfo.fromPlatform();
      final current = int.tryParse(pkg.buildNumber) ?? AppMeta.versionCode;
      if (info.latestVersionCode <= current) {
        setState(() => _updateStatus = 'Güncelsiniz (${pkg.version})');
      } else {
        setState(() => _updateStatus =
            'Yeni sürüm: ${info.latestVersionName}\nİndirme açılıyor…');
        final uri = Uri.parse(info.apkUrl);
        if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
          setState(() => _updateStatus = 'Tarayıcı açılamadı');
        }
      }
    } catch (e) {
      setState(() => _updateStatus = 'Kontrol başarısız: $e');
    } finally {
      if (mounted) setState(() => _checkingUpdate = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ProfileStore.instance.profile!;
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 11,
          color: ElEmegiColors.softBlueGray,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
      children: [
        Text(
          'Ayarlar',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        const FabrikaSectionTitle('Telefon sahibi'),
        FabrikaFormCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: ElEmegiColors.kilimRed.withValues(alpha: 0.12),
                child: const Icon(Icons.lock, color: ElEmegiColors.kilimRed, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.adSoyad,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'İlk kurulumda sabitlendi',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: ElEmegiColors.olive,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const FabrikaSectionTitle('Ödeme bilgisi'),
        FabrikaFormCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'IBAN',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                    ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _ibanController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  hintText: 'TR00 0000 0000 0000 0000 0000 00',
                ),
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\s]')),
                ],
                onChanged: (_) => _ibanSaved = false,
              ),
              const SizedBox(height: 8),
              FabrikaGradientButton(
                label: _ibanSaved ? 'Kayıtlı' : 'IBAN kaydet',
                icon: Icons.save_outlined,
                compact: true,
                onPressed: _saveIban,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const FabrikaSectionTitle('Uygulama'),
        FabrikaFormCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Column(
            children: [
              SwitchListTile(
                dense: true,
                visualDensity: _tileDensity,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                secondary: Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: ElEmegiColors.softBlueGray.withValues(alpha: 0.7),
                ),
                title: const Text('Bildirimler', style: TextStyle(fontSize: 14)),
                subtitle: Text('Yakında — şimdilik kapalı', style: subtitleStyle),
                value: _notificationsEnabled,
                onChanged: null,
              ),
              const Divider(height: 1, indent: 8, endIndent: 8),
              ListTile(
                dense: true,
                visualDensity: _tileDensity,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: const Icon(Icons.system_update_outlined, color: ElEmegiColors.teal, size: 20),
                title: const Text('Güncellemeyi kontrol et', style: TextStyle(fontSize: 14)),
                subtitle: Text(
                  _updateStatus ?? 'GitHub: fabrika360-updates',
                  style: subtitleStyle,
                  maxLines: 2,
                ),
                trailing: _checkingUpdate
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right, size: 20),
                onTap: _checkingUpdate ? null : _checkForUpdate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const FabrikaSectionTitle('Yönetim'),
        FabrikaFormCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          child: ListTile(
            dense: true,
            visualDensity: _tileDensity,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: Icon(
              Icons.admin_panel_settings_outlined,
              size: 20,
              color: ElEmegiColors.softBlueGray.withValues(alpha: 0.75),
            ),
            title: const Text('Yönetici paneli', style: TextStyle(fontSize: 14)),
            subtitle: Text('Kayıt yönetimi, ay/kişi raporu', style: subtitleStyle),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const FabrikaSectionTitle('Bilgi'),
        FabrikaFormCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          child: Column(
            children: [
              if (AppConfig.showUnitPriceListInSettings) ...[
                ListTile(
                  dense: true,
                  visualDensity: _tileDensity,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: const Icon(Icons.price_check_outlined, color: ElEmegiColors.teal, size: 20),
                  title: const Text('Birim ücret listesi', style: TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const UnitPricesScreen()),
                  ),
                ),
                const Divider(height: 1, indent: 8, endIndent: 8),
              ],
              ListTile(
                dense: true,
                visualDensity: _tileDensity,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: const Icon(Icons.info_outline, color: ElEmegiColors.teal, size: 20),
                title: const Text('Hakkında', style: TextStyle(fontSize: 14)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          AppMeta.developerCredit,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ElEmegiColors.softBlueGray,
                fontSize: 11,
              ),
        ),
        const SizedBox(height: 2),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snap) {
            final label = snap.hasData
                ? 'v${snap.data!.version} (${snap.data!.buildNumber})'
                : AppMeta.displayVersion;
            return Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: ElEmegiColors.olive,
                    fontSize: 10,
                  ),
            );
          },
        ),
      ],
    );
  }
}
