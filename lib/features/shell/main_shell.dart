import 'package:flutter/material.dart';

import '../../data/local/profile_store.dart';
import '../../data/records_store.dart';
import '../../data/remote/payment_notification_service.dart';
import '../../theme/el_emegi_colors.dart';
import '../../widgets/el_emegi_bottom_nav.dart';
import '../../widgets/el_emegi_brand_header.dart';
import '../../widgets/premium/screen_backdrop.dart';
import '../history/history_screen.dart';
import '../payment/payment_screen.dart';
import '../record/record_screen.dart';
import '../settings/settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    PaymentNotificationService.instance.onPaymentDeposited = _onPaymentDeposited;
    final uid = ProfileStore.instance.ownerUid;
    if (uid.isNotEmpty) {
      PaymentNotificationService.instance.start(uid);
    }
  }

  @override
  void dispose() {
    PaymentNotificationService.instance.stop();
    PaymentNotificationService.instance.onPaymentDeposited = null;
    _pageController.dispose();
    super.dispose();
  }

  void _onPaymentDeposited(String message, double? tutar) {
    if (!mounted) return;
    final text = tutar != null
        ? '$message\n${tutar.toStringAsFixed(2)} ₺'
        : message;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
      ),
    );
    RecordsStore.instance.refresh();
  }

  void _onTab(int i) {
    if (_index == i) return;
    setState(() => _index = i);
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    if (i == 1 || i == 2) {
      RecordsStore.instance.refresh();
    }
  }

  void _onPageChanged(int i) {
    if (_index == i) return;
    setState(() => _index = i);
    if (i == 1 || i == 2) {
      RecordsStore.instance.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ElEmegiColors.darkNavy,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ElEmegiBrandHeader(),
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const ScreenBackdrop(),
                PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    RecordScreen(
                      onSaved: () {
                        RecordsStore.instance.refresh();
                        _onTab(1);
                      },
                    ),
                    const HistoryScreen(),
                    const PaymentScreen(),
                    const SettingsScreen(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: ElEmegiBottomNav(
        currentIndex: _index,
        onTap: _onTab,
      ),
    );
  }
}
