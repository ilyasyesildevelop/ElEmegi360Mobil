import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/admin_credentials.dart';
import '../../data/admin_auth_service.dart';
import '../../data/dashboard_report_service.dart';
import '../../data/dashboard_store.dart';
import '../../models/work_record.dart';
import '../../theme/el_emegi_colors.dart';
import '../../theme/el_emegi_typography.dart';
import '../../widgets/currency_text.dart';
import '../../widgets/design/design_status_badge.dart';
import '../../widgets/fabrika_gradient_button.dart';
import '../../widgets/password_visibility_field.dart';
import '../../widgets/premium_glow_card.dart';
import 'dashboard_record_edit_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = true;
  bool _loggingIn = false;
  bool _loginError = false;
  bool? _wasAdminLoggedIn;
  static final _dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

  @override
  void initState() {
    super.initState();
    _wasAdminLoggedIn = AdminAuthService.instance.isLoggedIn;
    _syncLoginFields();
    AdminAuthService.instance.addListener(_onAdminChanged);
    if (AdminAuthService.instance.isLoggedIn) {
      DashboardStore.instance.refresh();
    }
  }

  @override
  void dispose() {
    AdminAuthService.instance.removeListener(_onAdminChanged);
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onAdminChanged() {
    final loggedIn = AdminAuthService.instance.isLoggedIn;
    if (loggedIn && _wasAdminLoggedIn != true) {
      DashboardStore.instance.refresh();
    }
    _wasAdminLoggedIn = loggedIn;
    if (mounted) setState(() {});
  }

  void _syncLoginFields() {
    final admin = AdminAuthService.instance;
    _usernameController.text =
        admin.savedUsername.isNotEmpty ? admin.savedUsername : AdminCredentials.defaultUsername;
    _passwordController.text =
        admin.savedPassword.isNotEmpty ? admin.savedPassword : AdminCredentials.defaultPassword;
    _rememberMe = admin.rememberMe;
  }

  Future<void> _login() async {
    setState(() {
      _loggingIn = true;
      _loginError = false;
    });
    final ok = await AdminAuthService.instance.login(
      _usernameController.text,
      _passwordController.text,
      rememberMe: _rememberMe,
    );
    if (!mounted) return;
    setState(() {
      _loggingIn = false;
      _loginError = !ok;
    });
    if (ok) await DashboardStore.instance.refresh();
  }

  Future<void> _logout() async {
    await AdminAuthService.instance.logout();
    await DashboardStore.instance.refresh();
  }

  Future<void> _pickWorker(BuildContext context) async {
    final store = DashboardStore.instance;
    final names = store.workerNames;
    if (names.isEmpty) return;

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: ElEmegiColors.cardDark,
      showDragHandle: true,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        children: names
            .map(
              (n) => ListTile(
                title: Text(n, style: const TextStyle(color: Colors.white)),
                trailing: n == store.selectedWorker
                    ? const Icon(Icons.check, color: ElEmegiColors.teal)
                    : null,
                onTap: () => Navigator.pop(ctx, n),
              ),
            )
            .toList(),
      ),
    );
    if (picked != null) store.setSelectedWorker(picked);
  }

  Future<void> _saveReport() async {
    final store = DashboardStore.instance;
    final worker = store.selectedWorker;
    if (worker == null || worker.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce kişi seçin')),
      );
      return;
    }
    final ok = await DashboardReportService.saveAndSharePdf(
      workerName: worker,
      month: store.focusMonth,
      records: store.records,
      approverName: AdminAuthService.instance.displayName,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'PDF hazır — paylaşım menüsünden kaydedin' : 'PDF oluşturulamadı'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElEmegiColors.darkNavy,
      appBar: AppBar(
        backgroundColor: ElEmegiColors.deepNavy,
        foregroundColor: Colors.white,
        title: const Text('Yönetici Paneli'),
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: AdminAuthService.instance,
        builder: (context, _) {
          if (!AdminAuthService.instance.isLoggedIn) {
            return _LoginGate(
              usernameController: _usernameController,
              passwordController: _passwordController,
              rememberMe: _rememberMe,
              loggingIn: _loggingIn,
              loginError: _loginError,
              onRememberChanged: (v) => setState(() => _rememberMe = v),
              onLogin: _login,
            );
          }
          return _DashboardBody(
            dateFormat: _dateFormat,
            onLogout: _logout,
            onPickWorker: () => _pickWorker(context),
            onSaveReport: _saveReport,
          );
        },
      ),
    );
  }
}

class _LoginGate extends StatelessWidget {
  const _LoginGate({
    required this.usernameController,
    required this.passwordController,
    required this.rememberMe,
    required this.loggingIn,
    required this.loginError,
    required this.onRememberChanged,
    required this.onLogin,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool loggingIn;
  final bool loginError;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          'Yönetici girişi',
          style: ElEmegiTypography.screenTitle(context),
        ),
        const SizedBox(height: 8),
        Text(
          'Varsayılan giriş: ${AdminCredentials.defaultUsername} / ${AdminCredentials.defaultPassword}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ElEmegiColors.olive,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          '1. Ayarlar → Yönetici paneli\n'
          '2. Yukarıdaki kullanıcı adı ve şifre ile giriş yapın\n'
          '3. Kişi ve ay seçerek tüm kayıtları görüntüleyin',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ElEmegiColors.softBlueGray,
                height: 1.45,
              ),
        ),
        const SizedBox(height: 20),
        PremiumGlowCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                size: 48,
                color: ElEmegiColors.tealLight.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Kullanıcı adı',
                  prefixIcon: const Icon(Icons.person_outline),
                  errorText: loginError ? ' ' : null,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              PasswordVisibilityField(
                controller: passwordController,
                errorText: loginError
                    ? (AdminAuthService.instance.sessionError ??
                        'Giriş başarısız — kullanıcı adı veya şifre hatalı')
                    : null,
                onSubmitted: (_) => onLogin(),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: rememberMe,
                onChanged: (v) => onRememberChanged(v ?? false),
                title: const Text('Beni hatırla'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 12),
              FabrikaGradientButton(
                label: loggingIn ? 'Giriş yapılıyor…' : 'Giriş yap',
                onPressed: loggingIn ? null : onLogin,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.dateFormat,
    required this.onLogout,
    required this.onPickWorker,
    required this.onSaveReport,
  });

  final DateFormat dateFormat;
  final VoidCallback onLogout;
  final VoidCallback onPickWorker;
  final VoidCallback onSaveReport;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DashboardStore.instance,
      builder: (context, _) {
        final store = DashboardStore.instance;
        final admin = AdminAuthService.instance;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DashboardHeader(
              adminName: admin.displayName,
              workerName: store.selectedWorker,
              monthLabel: store.monthLabel,
              onPickWorker: onPickWorker,
              onPrevMonth: store.previousMonth,
              onNextMonth: store.nextMonth,
              onLogout: onLogout,
              onRefresh: store.refresh,
              loading: store.loading,
            ),
            if (store.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  store.error!,
                  style: const TextStyle(color: ElEmegiColors.kilimRed, fontSize: 13),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _SummaryRow(count: store.filteredCount, total: store.filteredTotal),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: FabrikaGradientButton(
                label: 'Aylık PDF raporu kaydet / paylaş',
                icon: Icons.picture_as_pdf_outlined,
                onPressed: store.selectedWorker == null ? null : onSaveReport,
              ),
            ),
            Expanded(
              child: store.initialLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: ElEmegiColors.teal),
                    )
                  : store.records.isEmpty
                      ? RefreshIndicator(
                          color: ElEmegiColors.teal,
                          onRefresh: store.refresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.28,
                              ),
                              Center(
                                child: Text(
                                  store.selectedWorker == null
                                      ? (store.workerNames.isEmpty
                                          ? 'Henüz kayıt yok'
                                          : 'Kişi seçin')
                                      : 'Seçilen kişi ve ay için kayıt yok',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: ElEmegiColors.softBlueGray,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: ElEmegiColors.teal,
                          onRefresh: store.refresh,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: store.records.length,
                            itemBuilder: (context, i) {
                              final r = store.records[i];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _DashboardRecordCard(
                                  record: r,
                                  dateLabel: dateFormat.format(r.tarih),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.adminName,
    required this.workerName,
    required this.monthLabel,
    required this.onPickWorker,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onLogout,
    required this.onRefresh,
    required this.loading,
  });

  final String adminName;
  final String? workerName;
  final String monthLabel;
  final VoidCallback onPickWorker;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onLogout;
  final Future<void> Function() onRefresh;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ElEmegiColors.deepNavy, Color(0xFF1A2844)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard',
                      style: ElEmegiTypography.screenTitle(context).copyWith(
                        color: Colors.white,
                        fontSize: 22,
                      ),
                    ),
                    if (adminName.isNotEmpty)
                      Text(
                        adminName,
                        style: ElEmegiTypography.formLabel(context).copyWith(
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Yenile',
                onPressed: loading ? null : onRefresh,
                icon: const Icon(Icons.sync_rounded, color: ElEmegiColors.goldLight),
              ),
              IconButton(
                tooltip: 'Çıkış',
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Material(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onPickWorker,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.white.withValues(alpha: 0.7), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        workerName ?? 'Kişi seçin',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: onPrevMonth,
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_month_outlined, color: ElEmegiColors.tealLight, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      monthLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.count, required this.total});

  final int count;
  final double total;

  @override
  Widget build(BuildContext context) {
    return PremiumGlowCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kayıt', style: ElEmegiTypography.formLabel(context)),
                Text('$count', style: ElEmegiTypography.formValue(context)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Toplam tutar', style: ElEmegiTypography.formLabel(context)),
                CurrencyText(total, bold: true, color: ElEmegiColors.tealLight),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardRecordCard extends StatelessWidget {
  const _DashboardRecordCard({
    required this.record,
    required this.dateLabel,
  });

  final WorkRecord record;
  final String dateLabel;

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ElEmegiColors.cardDark,
        title: const Text('Kaydı sil', style: TextStyle(color: Colors.white)),
        content: Text(
          '$dateLabel\nBu kayıt kalıcı olarak silinecek.',
          style: const TextStyle(color: ElEmegiColors.threadCream),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Vazgeç')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil', style: TextStyle(color: ElEmegiColors.kilimRed)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final deleted = await DashboardStore.instance.adminDelete(record.kayitId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(deleted ? 'Kayıt silindi' : 'Kayıt silinemedi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumGlowCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(dateLabel, style: ElEmegiTypography.formValue(context).copyWith(fontSize: 14)),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20, color: ElEmegiColors.softBlueGray),
                onPressed: () => showDashboardRecordEditSheet(context, record),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: ElEmegiColors.kilimRed),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          Text(
            '${record.urunCinsi} · ${record.iscilikTuru}',
            style: ElEmegiTypography.formLabel(context),
          ),
          Text(
            '${record.olcuLabel} × ${record.adet}',
            style: ElEmegiTypography.formLabel(context).copyWith(fontSize: 11),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              DesignStatusBadge(status: record.status),
              const Spacer(),
              CurrencyText(record.tutar, color: ElEmegiColors.tealLight),
            ],
          ),
        ],
      ),
    );
  }
}
