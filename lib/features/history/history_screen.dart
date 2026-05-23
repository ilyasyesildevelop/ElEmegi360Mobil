import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/records_store.dart';
import '../../models/work_record.dart';
import '../../theme/el_emegi_colors.dart';
import '../../theme/el_emegi_typography.dart';
import '../../widgets/currency_text.dart';
import '../../widgets/design/design_status_badge.dart';
import '../../widgets/premium_glow_card.dart';
import 'record_edit_sheet.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static final _dateFormat = DateFormat('d MMMM yyyy', 'tr_TR');

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: RecordsStore.instance,
      builder: (context, _) {
        final store = RecordsStore.instance;
        if (store.loading && store.records.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: ElEmegiColors.teal),
          );
        }

        return RefreshIndicator(
          color: ElEmegiColors.teal,
          onRefresh: store.refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Geçmiş Kayıtlar',
                      style: ElEmegiTypography.screenTitle(context),
                    ),
                  ),
                  Material(
                    color: ElEmegiColors.cardDark.withValues(alpha: 0.8),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: store.refresh,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.sync_rounded, color: ElEmegiColors.goldLight, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (store.records.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Center(
                    child: Text(
                      store.error ?? 'Henüz kayıt yok',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: ElEmegiColors.softBlueGray,
                          ),
                    ),
                  ),
                )
              else
                ...store.records.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _HistoryCard(
                      record: r,
                      dateLabel: _dateFormat.format(r.tarih),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.record, required this.dateLabel});

  final WorkRecord record;
  final String dateLabel;

  String get _shortId {
    final id = record.kayitId;
    if (id.length <= 8) return id;
    return id.substring(id.length - 8);
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ElEmegiColors.cardDark,
        title: const Text('Kaydı sil', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Bu kayıt kalıcı olarak silinecek. Devam edilsin mi?',
          style: TextStyle(color: ElEmegiColors.threadCream),
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

    final deleted = await RecordsStore.instance.delete(record.kayitId);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(deleted ? 'Kayıt silindi' : 'Kayıt silinemedi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editable = record.canEdit;
    final labelStyle = ElEmegiTypography.formLabel(context).copyWith(fontSize: 11);
    final detailStyle = ElEmegiTypography.formLabel(context).copyWith(fontSize: 12);

    return PremiumGlowCard(
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(dateLabel, style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    Text('ID: $_shortId', style: labelStyle.copyWith(fontSize: 10)),
                    const SizedBox(width: 6),
                    DesignStatusBadge(status: record.status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.urunCinsi} · ${record.iscilikTuru}',
                  style: ElEmegiTypography.sectionInCard(context).copyWith(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.olcuLabel} · ${record.adet} adet',
                  style: detailStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                CurrencyText(
                  record.tutar,
                  bold: true,
                  color: ElEmegiColors.tealLight,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          if (editable) ...[
            _ActionIcon(
              icon: Icons.edit_outlined,
              color: ElEmegiColors.tealLight,
              tooltip: 'Düzenle',
              onTap: () => showRecordEditSheet(context, record),
            ),
            _ActionIcon(
              icon: Icons.delete_outline,
              color: ElEmegiColors.kilimRed,
              tooltip: 'Sil',
              onTap: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      icon: Icon(icon, size: 18, color: color),
    );
  }
}
