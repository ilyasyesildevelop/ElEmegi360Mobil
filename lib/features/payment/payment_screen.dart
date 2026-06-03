import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/records_store.dart';
import '../../models/record_status.dart';
import '../../models/work_record.dart';
import '../../theme/el_emegi_colors.dart';
import '../../theme/el_emegi_typography.dart';
import '../../widgets/currency_text.dart';
import '../../widgets/design/design_status_badge.dart';
import '../../widgets/premium/premium_hero_card.dart';
import '../../widgets/premium_glow_card.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RecordsStore.instance,
      builder: (context, _) {
        final store = RecordsStore.instance;
        final pending = store.pendingTotal;
        final pendingCount = store.pendingRecordCount;
        final periods = store.paymentPeriods;

        return RefreshIndicator(
          color: ElEmegiColors.teal,
          onRefresh: store.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              PremiumHeroCard(
                title: 'Ödenecek Toplam',
                amount: pending,
                subtitle: pendingCount > 0
                    ? 'Bekleyen $pendingCount kayıt bulunuyor'
                    : 'Bekleyen kayıt yok',
                goldAmount: true,
              ),
              const SizedBox(height: 22),
              Text(
                'Ödeme Geçmişi',
                style: ElEmegiTypography.screenTitle(context),
              ),
              const SizedBox(height: 12),
              if (periods.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: Text(
                      'Henüz dönem özeti yok',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ElEmegiColors.softBlueGray,
                          ),
                    ),
                  ),
                )
              else
                ...periods.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _PeriodCard(period: p),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.period});

  final PaymentPeriod period;

  @override
  Widget build(BuildContext context) {
    final paid = period.paid;
    final status = paid ? RecordStatus.odendi : RecordStatus.beklemede;

    return PremiumGlowCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        period.periodLabel,
                        style: ElEmegiTypography.sectionInCard(context).copyWith(
                          fontSize: 17,
                        ),
                      ),
                    ),
                    DesignStatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 14),
                _MetricRow(
                  label: 'Dönem Toplamı',
                  child: CurrencyText(
                    period.amount,
                    bold: true,
                    color: paid ? Colors.white : ElEmegiColors.goldLight,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                _MetricRow(
                  label: 'Kayıt Sayısı',
                  child: Text(
                    '${period.recordCount}',
                    style: ElEmegiTypography.formValue(context),
                  ),
                ),
                if (paid) ...[
                  const SizedBox(height: 6),
                  _MetricRow(
                    label: 'Ödeme Tarihi',
                    child: Text(
                      period.odemeTarihi != null
                          ? DateFormat('d MMMM yyyy', 'tr_TR')
                              .format(period.odemeTarihi!.toLocal())
                          : '—',
                      style: ElEmegiTypography.formLabel(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: ElEmegiColors.gold.withValues(alpha: 0.7),
            size: 28,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: ElEmegiTypography.formLabel(context)),
        ),
        Expanded(child: child),
      ],
    );
  }
}
