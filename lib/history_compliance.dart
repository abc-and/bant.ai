import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'constants/app_colors.dart';
import 'models.dart';

class HistoryCompliance extends StatefulWidget {
  final List<Violation> violations;
  final Function(int) onSetRetentionMonths;

  const HistoryCompliance({
    super.key,
    required this.violations,
    required this.onSetRetentionMonths,
  });

  @override
  State<HistoryCompliance> createState() => _HistoryComplianceState();
}

class _HistoryComplianceState extends State<HistoryCompliance> {
  String _timeFilter = 'all';
  String _searchQuery = '';
  String _typeFilter = 'all';
  int _retentionMonths = 6;

  List<Violation> get _resolvedViolations {
    return widget.violations
        .where((v) => v.status == ViolationStatus.resolved || v.status == ViolationStatus.dismissed)
        .toList();
  }

  List<Violation> get _filteredViolations {
    var list = _resolvedViolations;

    // Time filter
    final now = DateTime.now();
    if (_timeFilter == 'today') {
      list = list.where((v) {
        final resolved = v.resolvedDate ?? v.timestamp;
        return resolved.year == now.year &&
            resolved.month == now.month &&
            resolved.day == now.day;
      }).toList();
    } else if (_timeFilter == 'week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      list = list.where((v) {
        final resolved = v.resolvedDate ?? v.timestamp;
        return resolved.isAfter(weekAgo);
      }).toList();
    } else if (_timeFilter == 'month') {
      final monthAgo = now.subtract(const Duration(days: 30));
      list = list.where((v) {
        final resolved = v.resolvedDate ?? v.timestamp;
        return resolved.isAfter(monthAgo);
      }).toList();
    }

    // Type filter
    if (_typeFilter == 'overcapacity') {
      list = list.where((v) => v.type == ViolationType.overload).toList();
    } else if (_typeFilter == 'overspeed') {
      list = list.where((v) => v.type == ViolationType.overspeed).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      list = list.where((v) {
        final query = _searchQuery.toLowerCase();
        return v.unitId.toLowerCase().contains(query) ||
            v.operator.toLowerCase().contains(query) ||
            v.id.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildControlBar(),
        _buildSummaryCard(),
        Expanded(child: _buildHistoryList()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.history, color: AppColors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'History & Compliance Records',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'View resolved violations and manage data retention',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _showRetentionSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: Icon(Icons.settings, color: AppColors.success, size: 20),
            label: Text(
              'Retention Policy',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Unit ID, Operator, Violation ID...',
                prefixIcon: Icon(Icons.search, color: AppColors.grey500),
                filled: true,
                fillColor: AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          _buildFilterDropdown(
            _timeFilter,
            [
              {'value': 'all', 'label': 'All Time'},
              {'value': 'today', 'label': 'Today'},
              {'value': 'week', 'label': 'This Week'},
              {'value': 'month', 'label': 'This Month'},
            ],
            (value) => setState(() => _timeFilter = value),
          ),
          const SizedBox(width: 12),
          _buildFilterDropdown(
            _typeFilter,
            [
              {'value': 'all', 'label': 'All Types'},
              {'value': 'overcapacity', 'label': 'Overcapacity'},
              {'value': 'overspeed', 'label': 'Overspeeding'},
            ],
            (value) => setState(() => _typeFilter = value),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _exportAllHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.download, color: AppColors.white, size: 18),
            label: const Text(
              'Export Records',
              style: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String value,
    List<Map<String, String>> items,
    Function(String) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(
                    value: e['value']!,
                    child: Text(
                      e['label']!,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ))
              .toList(),
          onChanged: (v) => onChanged(v!),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalResolved = _resolvedViolations.length;
    final overload = _resolvedViolations
        .where((v) => v.type == ViolationType.overload)
        .length;
    final overspeed = _resolvedViolations
        .where((v) => v.type == ViolationType.overspeed)
        .length;

    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.check_circle,
              '$totalResolved',
              'Total Resolved',
              AppColors.success,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.grey200,
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.people,
              '$overload',
              'Overcapacity Cases',
              AppColors.error,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: AppColors.grey200,
            margin: const EdgeInsets.symmetric(horizontal: 24),
          ),
          Expanded(
            child: _buildStatItem(
              Icons.speed,
              '$overspeed',
              'Overspeeding Cases',
              AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.grey600,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    final violations = _filteredViolations;

    if (violations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: AppColors.grey400),
            const SizedBox(height: 16),
            Text(
              'No resolved violations found',
              style: TextStyle(
                color: AppColors.grey600,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: TextStyle(
                color: AppColors.grey500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: violations.length,
      itemBuilder: (context, index) => _buildHistoryCard(violations[index]),
    );
  }

  Widget _buildHistoryCard(Violation v) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey400.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: v.status == ViolationStatus.resolved
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.grey300.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                v.status == ViolationStatus.resolved
                    ? Icons.check_circle
                    : Icons.cancel,
                color: v.status == ViolationStatus.resolved
                    ? AppColors.success
                    : AppColors.grey500,
                size: 36,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        v.unitId,
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: v.type == ViolationType.overload
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          v.type == ViolationType.overload
                              ? 'OVERCAPACITY'
                              : 'OVERSPEED',
                          style: TextStyle(
                            color: v.type == ViolationType.overload
                                ? AppColors.error
                                : AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      if (v.repeatOffenseCount > 0) ...[
                        const SizedBox(width: 8),
                        Tooltip(
                          message: 'Repeat offender',
                          child: Icon(
                            Icons.warning,
                            color: AppColors.error,
                            size: 18,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Text(
                        v.operator,
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.route, size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Text(
                        'Route ${v.route}',
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: AppColors.grey500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          v.location,
                          style: TextStyle(
                            color: AppColors.grey500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    v.id,
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(v.resolvedDate ?? v.timestamp),
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.visibility, size: 22),
              color: AppColors.primary,
              tooltip: 'View Details',
              onPressed: () => _showDetails(v),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(Violation v) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              v.status == ViolationStatus.resolved
                  ? Icons.check_circle
                  : Icons.cancel,
              color: v.status == ViolationStatus.resolved
                  ? AppColors.success
                  : AppColors.grey500,
            ),
            const SizedBox(width: 12),
            const Text('Violation Record'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailSection('Basic Information', [
                  _buildDetailRow('Violation ID', v.id),
                  _buildDetailRow('Unit ID', v.unitId),
                  _buildDetailRow('Operator', v.operator),
                  _buildDetailRow('Route', v.route),
                  _buildDetailRow('Location', v.location),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Timeline', [
                  _buildDetailRow('Detected', _formatDate(v.timestamp)),
                  _buildDetailRow(
                    'Resolved',
                    _formatDate(v.resolvedDate ?? v.timestamp),
                  ),
                ]),
                const SizedBox(height: 16),
                _buildDetailSection('Violation Details', [
                  if (v.type == ViolationType.overload) ...[
                    _buildDetailRow('Type', 'Overcapacity'),
                    _buildDetailRow(
                      'Passengers',
                      '${v.details['passengers']}/${v.details['capacity']}',
                    ),
                    _buildDetailRow(
                      'Excess',
                      '${v.details['passengers'] - v.details['capacity']} passengers',
                    ),
                  ] else ...[
                    _buildDetailRow('Type', 'Overspeeding'),
                    _buildDetailRow('Speed', '${v.details['speed']} kph'),
                    _buildDetailRow('Limit', '${v.details['limit']} kph'),
                    _buildDetailRow(
                      'Excess',
                      '${v.details['speed'] - v.details['limit']} kph',
                    ),
                  ],
                ]),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: v.status == ViolationStatus.resolved
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.grey300.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: v.status == ViolationStatus.resolved
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.grey400.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        v.status == ViolationStatus.resolved
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: v.status == ViolationStatus.resolved
                            ? AppColors.success
                            : AppColors.grey500,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          v.status == ViolationStatus.resolved
                              ? 'This violation has been resolved'
                              : 'This violation was dismissed',
                          style: TextStyle(
                            color: v.status == ViolationStatus.resolved
                                ? AppColors.success
                                : AppColors.grey600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.primaryDark,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _showRetentionSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.schedule, color: AppColors.warning),
              const SizedBox(width: 12),
              const Text('Data Retention Policy'),
            ],
          ),
          content: SizedBox(
            width: 450,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set how long resolved violations should be retained before archival.',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Retention Period',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Slider(
                  value: _retentionMonths.toDouble(),
                  min: 1,
                  max: 24,
                  divisions: 23,
                  activeColor: AppColors.primary,
                  label: '$_retentionMonths months',
                  onChanged: (value) {
                    setDialogState(() {
                      _retentionMonths = value.toInt();
                    });
                  },
                ),
                Center(
                  child: Text(
                    '$_retentionMonths months',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Records older than $_retentionMonths months will be archived. You\'ll be prompted to export before deletion.',
                          style: TextStyle(
                            color: AppColors.grey700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                widget.onSetRetentionMonths(_retentionMonths);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Retention policy updated to $_retentionMonths months',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAllHistory() async {
    if (_filteredViolations.isEmpty) return;

    final pdf = pw.Document();

    for (int i = 0; i < _filteredViolations.length; i += 10) {
      final batch = _filteredViolations.sublist(
        i,
        i + 10 > _filteredViolations.length ? _filteredViolations.length : i + 10,
      );

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue700, width: 2),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'VIOLATION HISTORY & COMPLIANCE REPORT',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue900,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Mandaue City Government - Public Transport Regulation Office',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.blue700,
                            ),
                          ),
                          pw.Text(
                            'Generated: ${DateFormat('MMMM dd, yyyy HH:mm:ss').format(DateTime.now())}',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Report ID: HIST-${DateTime.now().millisecondsSinceEpoch}',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            'Page ${(i ~/ 10) + 1} of ${(_filteredViolations.length / 10).ceil()}',
                            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Summary Statistics
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.green50,
                    border: pw.Border.all(color: PdfColors.green700),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPdfStat('Total Records', '${_filteredViolations.length}'),
                      _buildPdfStat('Overcapacity', '${_filteredViolations.where((v) => v.type == ViolationType.overload).length}'),
                      _buildPdfStat('Overspeeding', '${_filteredViolations.where((v) => v.type == ViolationType.overspeed).length}'),
                      _buildPdfStat('Period', _timeFilter == 'all' ? 'All Time' : 
                        _timeFilter == 'today' ? 'Today' : 
                        _timeFilter == 'week' ? 'This Week' : 'This Month'),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                
                // Table Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                    border: pw.Border.all(color: PdfColors.grey400),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 2, child: pw.Text('VIOLATION ID', style: _headerStyle)),
                      pw.Expanded(flex: 1, child: pw.Text('UNIT', style: _headerStyle)),
                      pw.Expanded(flex: 2, child: pw.Text('OPERATOR', style: _headerStyle)),
                      pw.Expanded(flex: 1, child: pw.Text('ROUTE', style: _headerStyle)),
                      pw.Expanded(flex: 1, child: pw.Text('TYPE', style: _headerStyle)),
                      pw.Expanded(flex: 2, child: pw.Text('LOCATION', style: _headerStyle)),
                      pw.Expanded(flex: 1, child: pw.Text('DETECTED', style: _headerStyle)),
                      pw.Expanded(flex: 1, child: pw.Text('RESOLVED', style: _headerStyle)),
                      pw.Expanded(flex: 1, child: pw.Text('STATUS', style: _headerStyle)),
                    ],
                  ),
                ),
                
                // Violation Records
                for (final v in batch) ...[
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                    ),
                    child: pw.Row(
                      children: [
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(v.id, style: _cellStyle),
                                if (v.repeatOffenseCount > 0)
                                  pw.Text(
                                    'Repeat: ${v.repeatOffenseCount} prior',
                                    style: pw.TextStyle(
                                      fontSize: 7,
                                      color: PdfColors.red700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(v.unitId, style: _cellStyle),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(v.operator, style: _cellStyle),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.blue50,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                              ),
                              child: pw.Center(
                                child: pw.Text(v.route, style: _cellStyle),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: pw.BoxDecoration(
                                color: v.type == ViolationType.overload ? PdfColors.red50 : PdfColors.orange50,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                                border: pw.Border.all(
                                  color: v.type == ViolationType.overload ? PdfColors.red300 : PdfColors.orange300,
                                ),
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  v.type == ViolationType.overload ? 'OVERCAPACITY' : 'OVERSPEED',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                    color: v.type == ViolationType.overload ? PdfColors.red900 : PdfColors.orange900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 2,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              v.location.length > 40 ? '${v.location.substring(0, 40)}...' : v.location,
                              style: _cellStyle,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              DateFormat('MM/dd\nHH:mm').format(v.timestamp),
                              style: _cellStyle,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              DateFormat('MM/dd\nHH:mm').format(v.resolvedDate ?? v.timestamp),
                              style: _cellStyle,
                            ),
                          ),
                        ),
                        pw.Expanded(
                          flex: 1,
                          child: pw.Container(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: pw.BoxDecoration(
                                color: v.status == ViolationStatus.resolved ? PdfColors.green50 : PdfColors.grey200,
                                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  v.status == ViolationStatus.resolved ? 'RESOLVED' : 'DISMISSED',
                                  style: pw.TextStyle(
                                    fontSize: 8,
                                    fontWeight: pw.FontWeight.bold,
                                    color: v.status == ViolationStatus.resolved ? PdfColors.green900 : PdfColors.grey700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Details Section for each violation
                  pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      border: pw.Border(
                        left: pw.BorderSide(color: PdfColors.grey300),
                        right: pw.BorderSide(color: PdfColors.grey300),
                        bottom: pw.BorderSide(color: PdfColors.grey300),
                      ),
                    ),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('VIOLATION SPECIFICS:', style: _subHeaderStyle),
                              pw.SizedBox(height: 2),
                              if (v.type == ViolationType.overload) ...[
                                pw.Text('• Capacity: ${v.details['capacity']} persons', style: _detailStyle),
                                pw.Text('• Actual: ${v.details['passengers']} persons', style: _detailStyle),
                                pw.Text('• Excess: ${v.details['passengers'] - v.details['capacity']} persons', style: _detailStyle),
                              ] else ...[
                                pw.Text('• Speed Limit: ${v.details['limit']} km/h', style: _detailStyle),
                                pw.Text('• Detected: ${v.details['speed']} km/h', style: _detailStyle),
                                pw.Text('• Excess: ${v.details['speed'] - v.details['limit']} km/h', style: _detailStyle),
                              ],
                            ],
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('RESOLUTION:', style: _subHeaderStyle),
                              pw.SizedBox(height: 2),
                              if (v.penalty != null && v.penalty!.isNotEmpty)
                                pw.Text('• Penalty: ₱${v.penalty}', style: _detailStyle),
                              pw.Text('• Repeat Offenses: ${v.repeatOffenseCount}', style: _detailStyle),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 4),
                ],
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${_filteredViolations.length} records to PDF'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  // Helper styles for PDF
  final _headerStyle = pw.TextStyle(
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.blue900,
  );

  final _cellStyle = const pw.TextStyle(fontSize: 8);

  final _subHeaderStyle = pw.TextStyle(
    fontSize: 9,
    fontWeight: pw.FontWeight.bold,
    color: PdfColors.grey700,
  );

  final _detailStyle = const pw.TextStyle(fontSize: 8);

  // Helper method for PDF stats
  pw.Widget _buildPdfStat(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
        pw.SizedBox(height: 2),
        pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}