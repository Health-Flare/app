import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:health_flare/core/providers/database_provider.dart';
import 'package:health_flare/core/providers/profile_provider.dart';
import 'package:health_flare/features/reports/models/report_config.dart';
import 'package:health_flare/features/reports/services/csv_report_service.dart';
import 'package:health_flare/features/reports/services/pdf_report_service.dart';
import 'package:health_flare/features/reports/services/report_query_service.dart';

enum ReportFormat { pdf, csv }

/// Holds the user's current report configuration.
final reportConfigProvider =
    StateNotifierProvider<ReportConfigNotifier, ReportConfig>(
      (ref) => ReportConfigNotifier(),
    );

class ReportConfigNotifier extends StateNotifier<ReportConfig> {
  ReportConfigNotifier() : super(ReportConfig());

  void update(ReportConfig config) => state = config;
}

/// Exposes the report-generation action. Returns an error string or null.
final reportGeneratorProvider = Provider(_ReportGenerator.new);

class _ReportGenerator {
  _ReportGenerator(this._ref);
  final Ref _ref;

  static final _fileFmt = DateFormat('yyyy-MM-dd');

  /// Generates a report in [format] and opens the OS share sheet.
  ///
  /// Returns an error message string on failure, or null on success.
  Future<String?> generate(ReportFormat format) async {
    final isar = _ref.read(isarProvider);
    final profile = _ref.read(activeProfileDataProvider);
    final config = _ref.read(reportConfigProvider);

    if (profile == null) return 'No active profile.';
    if (!config.hasDataTypes) return 'Select at least one data type.';
    if (!config.customRangeValid) return 'End date must be after start date.';

    try {
      final data = await ReportQueryService.query(
        isar: isar,
        profileId: profile.id,
        profileName: profile.name,
        config: config,
      );

      final dir = await getTemporaryDirectory();
      final safeName = profile.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final dateStr = _fileFmt.format(DateTime.now());

      if (format == ReportFormat.pdf) {
        final bytes = await PdfReportService.generate(data);
        final file = File('${dir.path}/${safeName}_$dateStr.pdf');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([
          XFile(file.path, mimeType: 'application/pdf'),
        ], subject: 'Health report — ${profile.name}');
      } else {
        final csv = CsvReportService.generate(data);
        final file = File('${dir.path}/${safeName}_$dateStr.csv');
        await file.writeAsString(csv);
        await Share.shareXFiles([
          XFile(file.path, mimeType: 'text/csv'),
        ], subject: 'Health data — ${profile.name}');
      }

      return null;
    } catch (e) {
      return 'Report generation failed: $e';
    }
  }
}
