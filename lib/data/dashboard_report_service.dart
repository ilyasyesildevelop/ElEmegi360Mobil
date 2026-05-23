import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/work_record.dart';

/// Vardiya360 benzeri aylık PDF raporu — kaydet / paylaş.
class DashboardReportService {
  static const _company = 'EKO HALI';

  static Future<bool> saveAndSharePdf({
    required String workerName,
    required DateTime month,
    required List<WorkRecord> records,
    required String approverName,
  }) async {
    try {
      final bytes = await _buildPdf(
        workerName: workerName,
        month: month,
        records: records,
        approverName: approverName,
      );
      final fileName = _fileName(workerName, month);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: fileName)],
        subject: 'El Emeği 360 — $workerName',
        text: 'Aylık el emeği raporu',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  static String _fileName(String workerName, DateTime month) {
    final monthKey = DateFormat('yyyy-MM').format(month);
    final safe = workerName
        .toUpperCase()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return 'Aylik El Emegi Raporu - $safe - $monthKey.pdf';
  }

  static Future<List<int>> _buildPdf({
    required String workerName,
    required DateTime month,
    required List<WorkRecord> records,
    required String approverName,
  }) async {
    final monthLabel = DateFormat('MMMM yyyy', 'tr_TR').format(month);
    final total = records.fold(0.0, (s, r) => s + r.tutar);
    final dateFmt = DateFormat('d.MM.yyyy', 'tr_TR');
    final now = DateFormat('d.MM.yyyy', 'tr_TR').format(DateTime.now());

    final regular = await PdfGoogleFonts.notoSansRegular();
    final bold = await PdfGoogleFonts.notoSansBold();

    pw.Widget hCell(String t) => pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(t, style: pw.TextStyle(font: bold, fontSize: 8)),
        );
    pw.Widget dCell(String t, {bool right = false}) => pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.Text(
            t,
            style: pw.TextStyle(font: regular, fontSize: 8),
            textAlign: right ? pw.TextAlign.right : pw.TextAlign.left,
          ),
        );

    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          hCell('TARİH'),
          hCell('ÜRÜN'),
          hCell('İŞÇİLİK'),
          hCell('ÖLÇÜ'),
          hCell('ADET'),
          hCell('TUTAR (₺)'),
        ],
      ),
      ...records.map(
        (r) => pw.TableRow(
          children: [
            dCell(dateFmt.format(r.tarih)),
            dCell(r.urunCinsi),
            dCell(r.iscilikTuru),
            dCell(r.olcuLabel),
            dCell('${r.adet}', right: true),
            dCell(r.tutar.toStringAsFixed(2), right: true),
          ],
        ),
      ),
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey200),
        children: [
          dCell('TOPLAM', right: false),
          dCell(''),
          dCell(''),
          dCell(''),
          dCell('${records.length}', right: true),
          dCell(total.toStringAsFixed(2), right: true),
        ],
      ),
    ];

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => [
          pw.Text(
            'AYLIK EL EMEĞİ RAPORU',
            style: pw.TextStyle(font: bold, fontSize: 16),
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(_company, style: pw.TextStyle(font: regular, fontSize: 10)),
              pw.Text('Dönem: $monthLabel', style: pw.TextStyle(font: regular, fontSize: 10)),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(height: 2, color: PdfColors.teal),
          pw.SizedBox(height: 14),
          pw.Text('Personel: $workerName', style: pw.TextStyle(font: bold, fontSize: 11)),
          pw.SizedBox(height: 8),
          pw.Text(
            'İşbu rapor, belirtilen dönemde gerçekleştirilen el emeği kayıtlarını '
            'göstermektedir. Aşağıdaki bilgilerin doğruluğunu beyan ve tasdik ederim.',
            style: pw.TextStyle(font: regular, fontSize: 9),
          ),
          pw.SizedBox(height: 16),
          if (records.isEmpty)
            pw.Text(
              'Bu dönem için kayıt bulunmamaktadır.',
              style: pw.TextStyle(font: regular, fontSize: 10, color: PdfColors.grey700),
            )
          else
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.1),
                1: const pw.FlexColumnWidth(1.4),
                2: const pw.FlexColumnWidth(1.4),
                3: const pw.FlexColumnWidth(1.0),
                4: const pw.FlexColumnWidth(0.6),
                5: const pw.FlexColumnWidth(0.9),
              },
              children: tableRows,
            ),
          pw.SizedBox(height: 28),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _sigBlock(regular, bold, 'Personel Onayı', workerName, now),
              _sigBlock(
                regular,
                bold,
                'Yönetici Onayı',
                approverName.isNotEmpty ? approverName : 'Yönetici',
                now,
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'El Emeği 360 · Fabrika 360 Suite',
              style: pw.TextStyle(font: regular, fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _sigBlock(
    pw.Font regular,
    pw.Font bold,
    String title,
    String name,
    String date,
  ) {
    return pw.SizedBox(
      width: 200,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 9)),
          pw.SizedBox(height: 24),
          pw.Container(width: 180, height: 1, color: PdfColors.grey600),
          pw.SizedBox(height: 4),
          pw.Text(name, style: pw.TextStyle(font: regular, fontSize: 9)),
          pw.Text('Tarih: $date', style: pw.TextStyle(font: regular, fontSize: 8)),
        ],
      ),
    );
  }
}
