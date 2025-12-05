import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'constants/app_colors.dart';
import 'models.dart';

class ViolationsManagement extends StatefulWidget {
  final List<Violation> violations;
  final VoidCallback onUpdate;

  const ViolationsManagement({
    super.key,
    required this.violations,
    required this.onUpdate,
  });

  @override
  State<ViolationsManagement> createState() => _ViolationsManagementState();
}

class _ViolationsManagementState extends State<ViolationsManagement> {
  String _searchQuery = '';
  ViolationType? _typeFilter;
  Violation? _selectedViolation;
  final Set<String> _selectedIds = {};

  List<Violation> get _filteredViolations {
    return widget.violations.where((v) {
      if (v.status == ViolationStatus.detected || 
          v.status == ViolationStatus.resolved || 
          v.status == ViolationStatus.dismissed) return false;
      
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!v.unitId.toLowerCase().contains(query) &&
            !v.operator.toLowerCase().contains(query) &&
            !v.location.toLowerCase().contains(query) &&
            !v.id.toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_typeFilter != null && v.type != _typeFilter) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _buildHeader(),
              _buildControlBar(),
              _buildStatsBar(),
              _buildViolationsTable(),
            ],
          ),
        ),
        if (_selectedViolation != null) _buildDetailsPanel(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
            child: const Icon(Icons.assignment, color: AppColors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Violations Management',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Generate formal incident reports and manage violations',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
  final verified = _filteredViolations.length;
  final overload = _filteredViolations.where((v) => v.type == ViolationType.overload).length;
  final overspeed = _filteredViolations.where((v) => v.type == ViolationType.overspeed).length;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
    decoration: BoxDecoration(
      color: AppColors.grey50,
      border: Border(bottom: BorderSide(color: AppColors.grey200)),
    ),
    child: Row(
      children: [
        Expanded(child: _buildCompactStatChip('Total Verified', verified, AppColors.primary, Icons.verified_user)),
        const SizedBox(width: 8), // Reduced spacing
        Expanded(child: _buildCompactStatChip('Overloading', overload, AppColors.error, Icons.people)),
        const SizedBox(width: 8), // Reduced spacing
        Expanded(child: _buildCompactStatChip('Overspeeding', overspeed, AppColors.orange, Icons.speed)),
      ],
    ),
  );
}

Widget _buildCompactStatChip(String label, int count, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(10), // Reduced padding
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.3), width: 1.5),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6), // Reduced padding
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16), // Smaller icon
        ),
        const SizedBox(width: 8), // Reduced spacing
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: color,
                  fontSize: 18, // Smaller font
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 10, // Much smaller font
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
              ),
            ],
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
                hintText: 'Search violations...',
                prefixIcon: Icon(Icons.search, color: AppColors.grey500),
                filled: true,
                fillColor: AppColors.grey50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.grey300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _typeFilter?.toString().split('.').last ?? 'All',
                items: ['All', 'overload', 'overspeed']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _typeFilter = v == 'All'
                    ? null
                    : ViolationType.values.firstWhere((e) => e.toString().split('.').last == v)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: _selectedIds.isEmpty ? null : _exportSelected,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.grey300,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: Icon(Icons.picture_as_pdf, 
              color: _selectedIds.isEmpty ? AppColors.grey500 : AppColors.white),
            label: Text(
              'Generate Reports (${_selectedIds.length})',
              style: TextStyle(
                color: _selectedIds.isEmpty ? AppColors.grey500 : AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationsTable() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(16),
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
        child: Column(
          children: [
            _buildTableHeader(),
            Expanded(
              child: _filteredViolations.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _filteredViolations.length,
                      itemBuilder: (context, index) => _buildTableRow(_filteredViolations[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: AppColors.grey400),
          const SizedBox(height: 16),
          Text('No verified violations', 
            style: TextStyle(color: AppColors.grey600, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Verified violations will appear here',
            style: TextStyle(color: AppColors.grey500, fontSize: 13)),
        ],
      ),
    );
  }

 Widget _buildTableHeader() {
  final allSelected = _selectedIds.length == _filteredViolations.length && _filteredViolations.isNotEmpty;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [AppColors.primary.withOpacity(0.08), AppColors.primary.withOpacity(0.05)],
      ),
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      border: Border(bottom: BorderSide(color: AppColors.primary.withOpacity(0.2), width: 2)),
    ),
    child: Row(
      children: [
        // Checkbox
        SizedBox(
          width: 36,
          child: Checkbox(
            value: allSelected,
            onChanged: (v) {
              setState(() {
                if (v!) {
                  _selectedIds.addAll(_filteredViolations.map((e) => e.id));
                } else {
                  _selectedIds.clear();
                }
              });
            },
          ),
        ),
        // ID
        SizedBox(
          width: 140,
          child: const Text('ID', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            textAlign: TextAlign.left),
        ),
        // UNIT
        SizedBox(
          width: 70,
          child: const Text('UNIT', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            textAlign: TextAlign.center),
        ),
        // OPERATOR
        SizedBox(
          width: 140,
          child: const Text('OPERATOR', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            textAlign: TextAlign.left),
        ),
        // ROUTE
        SizedBox(
          width: 50,
          child: const Text('ROUTE', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            textAlign: TextAlign.center),
        ),
        // TYPE
        SizedBox(
          width: 100,
          child: const Text('TYPE', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            textAlign: TextAlign.center),
        ),
        // LOCATION
        Expanded(
          child: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text('LOCATION', 
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
              textAlign: TextAlign.left),
          ),
        ),
        // TIME
        SizedBox(
          width: 80,
          child: const Text('TIME', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            textAlign: TextAlign.center),
        ),
        // ACTIONS
        SizedBox(
          width: 80,
          child: const Text('ACTIONS', 
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
            textAlign: TextAlign.left),
        ),
      ],
    ),
  );
}


  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.5)),
    );
  }

  Widget _buildTableRow(Violation v) {
  final isSelected = _selectedIds.contains(v.id);
  final isRowSelected = _selectedViolation?.id == v.id;

  return InkWell(
    onTap: () => setState(() => _selectedViolation = v),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Reduced padding
      decoration: BoxDecoration(
        color: isRowSelected ? AppColors.primary.withOpacity(0.05) : null,
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 36,
            child: Checkbox(
              value: isSelected,
              onChanged: (val) {
                setState(() {
                  if (val!) _selectedIds.add(v.id); else _selectedIds.remove(v.id);
                });
              },
            ),
          ),
          // ID
          SizedBox(
            width: 140, // Reduced width
            child: Text(v.id, 
              style: const TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left),
          ),
          // UNIT
          SizedBox(
            width: 70, // Reduced width
            child: Center(
              child: _buildCompactUnitBadge(v.unitId),
            ),
          ),
          // OPERATOR
          SizedBox(
            width: 140, // Reduced width
            child: Text(v.operator, 
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left),
          ),
          // ROUTE
          SizedBox(
            width: 50, // Reduced width
            child: Center(
              child: _buildCompactRouteBadge(v.route),
            ),
          ),
          // TYPE
          SizedBox(
            width: 100, // Reduced width
            child: Center(
              child: _buildCompactTypeBadge(v),
            ),
          ),
          // LOCATION
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 10, color: AppColors.grey500), // Smaller icon
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(v.location.split(',').first, 
                      style: const TextStyle(fontSize: 10), 
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left),
                  ),
                ],
              ),
            ),
          ),
          // TIME
          SizedBox(
            width: 80, // Reduced width
            child: Text(
              DateFormat('MM/dd HH:mm').format(v.timestamp),
              style: TextStyle(fontSize: 10, color: AppColors.grey700),
              textAlign: TextAlign.center,
            ),
          ),
          // ACTIONS
          SizedBox(
            width: 80, // Reduced width
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, size: 16), // Smaller icon
                  color: AppColors.primary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => setState(() => _selectedViolation = v),
                ),
                if (v.repeatOffenseCount > 2)
                  Padding(
                    padding: const EdgeInsets.only(left: 2.0),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.warning, color: AppColors.error, size: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Compact versions of the badge builders
Widget _buildCompactUnitBadge(String unitId) {
  return Container(
    constraints: const BoxConstraints(minWidth: 40, maxWidth: 60),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.primaryDark.withOpacity(0.1),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: AppColors.primaryDark.withOpacity(0.2)),
    ),
    child: Text(unitId, 
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: AppColors.primaryDark),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis),
  );
}

Widget _buildCompactRouteBadge(String route) {
  return Container(
    constraints: const BoxConstraints(minWidth: 30, maxWidth: 40),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(route, 
      style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 10),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis),
  );
}

Widget _buildCompactTypeBadge(Violation v) {
  final isOverload = v.type == ViolationType.overload;
  final color = isOverload ? AppColors.error : AppColors.orange;
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(5),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(isOverload ? Icons.people : Icons.speed, size: 10, color: color),
        const SizedBox(width: 3),
        Text(isOverload ? 'Overload' : 'Overspeed',
          style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

  Widget _buildDetailsPanel() {
    final v = _selectedViolation!;
    final isOverload = v.type == ViolationType.overload;
    final color = isOverload ? AppColors.error : AppColors.orange;
    
    return Container(
      width: 420,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(left: BorderSide(color: AppColors.grey200, width: 2)),
        boxShadow: [
          BoxShadow(color: AppColors.black.withOpacity(0.1), blurRadius: 12, offset: const Offset(-4, 0)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
              boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Icon(isOverload ? Icons.people : Icons.speed, color: AppColors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isOverload ? 'Overloading Violation' : 'Overspeeding Violation',
                        style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Violation Details', 
                        style: TextStyle(color: AppColors.white.withOpacity(0.9), fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.white),
                  onPressed: () => setState(() => _selectedViolation = null),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildInfoCard(v),
                  const SizedBox(height: 16),
                  _buildViolationDetailsCard(v),
                  if (v.repeatOffenseCount > 0) ...[
                    const SizedBox(height: 16),
                    _buildRepeatOffenderWarning(v),
                  ],
                  const SizedBox(height: 16),
                  _buildEvidenceSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(v),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Violation v) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.grey50, AppColors.white]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          _buildDetailRow('Violation ID', v.id, Icons.fingerprint),
          _buildDetailRow('Unit ID', v.unitId, Icons.directions_bus),
          _buildDetailRow('Operator', v.operator, Icons.business),
          _buildDetailRow('Route', v.route, Icons.route),
          _buildDetailRow('Location', v.location, Icons.location_on),
          _buildDetailRow('Date & Time', DateFormat('MM/dd/yyyy HH:mm').format(v.timestamp), Icons.access_time),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey600),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.grey600, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationDetailsCard(Violation v) {
    final isOverload = v.type == ViolationType.overload;
    final color = isOverload ? AppColors.error : AppColors.orange;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Icon(isOverload ? Icons.people : Icons.speed, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(isOverload ? 'OVERLOADING DETAILS' : 'OVERSPEEDING DETAILS',
                style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ],
          ),
          const Divider(height: 24),
          if (isOverload) ...[
            _buildMetricRow('Capacity', '${v.details['capacity']} persons', Icons.group, AppColors.grey700),
            _buildMetricRow('Actual', '${v.details['passengers']} persons', Icons.people_alt, color, isBold: true),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXCESS PASSENGERS', 
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('${v.details['passengers'] - v.details['capacity']} persons over capacity',
                          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildMetricRow('Speed Limit', '${v.details['limit']} km/h', Icons.speed, AppColors.grey700),
            _buildMetricRow('Detected Speed', '${v.details['speed']} km/h', Icons.speed, color, isBold: true),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: color, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXCESS SPEED', 
                          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                        Text('${v.details['speed'] - v.details['limit']} km/h over limit',
                          style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: AppColors.grey700))),
          Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildRepeatOffenderWarning(Violation v) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: AppColors.error, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('REPEAT OFFENDER', 
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${v.repeatOffenseCount} prior violations recorded',
                  style: TextStyle(color: AppColors.error.withOpacity(0.8), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceSection() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, size: 56, color: AppColors.grey400),
            const SizedBox(height: 12),
            Text('Evidence Photo', style: TextStyle(color: AppColors.grey600, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Violation v) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _generateIncidentReport(v),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.picture_as_pdf, color: AppColors.white),
            label: const Text('Generate Formal Report', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _markAsResolved(v),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: Icon(Icons.check_circle, color: AppColors.white),
            label: Text('Mark as Resolved', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 8),
        Text('Note: Mark as resolved after regulatory actions are completed',
          style: TextStyle(color: AppColors.grey600, fontSize: 11, fontStyle: FontStyle.italic),
          textAlign: TextAlign.center),
      ],
    );
  }

  void _markAsResolved(Violation v) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            const Text('Confirm Resolution'),
          ],
        ),
        content: const Text('Are you sure you want to mark this violation as resolved?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              setState(() {
                v.status = ViolationStatus.resolved;
                v.resolvedDate = DateTime.now();
                _selectedViolation = null;
              });
              widget.onUpdate();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Violation ${v.id} marked as resolved'), backgroundColor: AppColors.success),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Confirm', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _generateIncidentReport(Violation v) async {
    final pdf = pw.Document();
    final isOverload = v.type == ViolationType.overload;
    
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
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'OFFICIAL INCIDENT REPORT',
                              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                            ),
                            pw.SizedBox(height: 4),
                            pw.Text(
                              'Mandaue City Government',
                              style: pw.TextStyle(fontSize: 12, color: PdfColors.blue800),
                            ),
                            pw.Text(
                              'Public Transport Regulation Office',
                              style: pw.TextStyle(fontSize: 10, color: PdfColors.blue700),
                            ),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Text(
                              'Report No: ${v.id}',
                              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                            ),
                            pw.Text(
                              'Generated: ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                            ),
                            pw.Text(
                              'Time: ${DateFormat('HH:mm:ss').format(DateTime.now())}',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 24),
              
              // Classification
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: isOverload ? PdfColors.red50 : PdfColors.orange50,
                  border: pw.Border.all(
                    color: isOverload ? PdfColors.red700 : PdfColors.orange700,
                    width: 1.5,
                  ),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'VIOLATION TYPE: ',
                      style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text(
                      isOverload ? 'PASSENGER OVERLOADING' : 'SPEED LIMIT VIOLATION',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: isOverload ? PdfColors.red900 : PdfColors.orange900,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              
              // Vehicle Information
              pw.Text('I. VEHICLE INFORMATION', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Container(height: 1, color: PdfColors.grey400, margin: const pw.EdgeInsets.symmetric(vertical: 8)),
              _buildPdfRow('Unit Identification Number', v.unitId),
              _buildPdfRow('Registered Operator', v.operator),
              _buildPdfRow('Designated Route', 'Route ${v.route}'),
              pw.SizedBox(height: 16),
              
              // Incident Details
              pw.Text('II. INCIDENT DETAILS', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Container(height: 1, color: PdfColors.grey400, margin: const pw.EdgeInsets.symmetric(vertical: 8)),
              _buildPdfRow('Date of Incident', DateFormat('MMMM dd, yyyy').format(v.timestamp)),
              _buildPdfRow('Time of Incident', DateFormat('HH:mm:ss').format(v.timestamp)),
              _buildPdfRow('Location', v.location),
              _buildPdfRow('Coordinates', 'Lat: ${v.lat.toStringAsFixed(6)}, Lng: ${v.lng.toStringAsFixed(6)}'),
              pw.SizedBox(height: 16),
              
              // Violation Specifics
              pw.Text('III. VIOLATION SPECIFICS', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Container(height: 1, color: PdfColors.grey400, margin: const pw.EdgeInsets.symmetric(vertical: 8)),
              
              if (isOverload) ...[
                _buildPdfRow('Legal Passenger Capacity', '${v.details['capacity']} persons'),
                _buildPdfRow('Detected Passenger Count', '${v.details['passengers']} persons'),
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 8, bottom: 8),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red100,
                    border: pw.Border.all(color: PdfColors.red700),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text('EXCESS PASSENGERS: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        '${v.details['passengers'] - v.details['capacity']} persons (${((v.details['passengers'] - v.details['capacity']) / v.details['capacity'] * 100).toStringAsFixed(1)}% over capacity)',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red900),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                _buildPdfRow('Posted Speed Limit', '${v.details['limit']} km/h'),
                _buildPdfRow('Detected Vehicle Speed', '${v.details['speed']} km/h'),
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 8, bottom: 8),
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.orange100,
                    border: pw.Border.all(color: PdfColors.orange700),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Text('EXCESS SPEED: ', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        '${v.details['speed'] - v.details['limit']} km/h (${((v.details['speed'] - v.details['limit']) / v.details['limit'] * 100).toStringAsFixed(1)}% over limit)',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.orange900),
                      ),
                    ],
                  ),
                ),
              ],
              
              pw.SizedBox(height: 16),
              
              // Violation History
              if (v.repeatOffenseCount > 0) ...[
                pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red50,
                    border: pw.Border.all(color: PdfColors.red700, width: 2),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '⚠ REPEAT OFFENDER ALERT',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red900),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Text(
                        'This operator has ${v.repeatOffenseCount} prior recorded violation(s) in the system.',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.red800),
                      ),
                      pw.Text(
                        'Enhanced penalties may apply as per local ordinances.',
                        style: pw.TextStyle(fontSize: 9, color: PdfColors.red700, fontStyle: pw.FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),
              ],
              
              // Legal Notice
              pw.Text('IV. REGULATORY ACTION', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
              pw.Container(height: 1, color: PdfColors.grey400, margin: const pw.EdgeInsets.symmetric(vertical: 8)),
              pw.Text(
                'This incident report serves as official documentation of a public transport regulation violation. '
                'The operator is hereby notified of this violation and may be subject to penalties as prescribed under '
                'local ordinances and Republic Act No. 4136 (Land Transportation and Traffic Code).',
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.5),
                textAlign: pw.TextAlign.justify,
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'The operator has the right to contest this violation by filing an appeal with the Public Transport '
                'Regulation Office within fifteen (15) working days from receipt of this report.',
                style: const pw.TextStyle(fontSize: 9, lineSpacing: 1.5),
                textAlign: pw.TextAlign.justify,
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.only(top: 16),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('_____________________________', style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 4),
                            pw.Text('Authorized Officer', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            pw.Text('Public Transport Regulation Office', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                          ],
                        ),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('_____________________________', style: const pw.TextStyle(fontSize: 9)),
                            pw.SizedBox(height: 4),
                            pw.Text('Date', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 16),
                    pw.Text(
                      'Document authenticity can be verified at: www.mandaue.gov.ph/verify',
                      style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 180,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSelected() async {
    final selectedViolations = widget.violations.where((v) => _selectedIds.contains(v.id)).toList();
    if (selectedViolations.isEmpty) return;

    final pdf = pw.Document();
    for (final v in selectedViolations) {
      final isOverload = v.type == ViolationType.overload;
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    border: pw.Border.all(color: PdfColors.blue700, width: 2),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('OFFICIAL INCIDENT REPORT',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.Text('Mandaue City Government - Public Transport Regulation Office',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.blue700)),
                      pw.SizedBox(height: 8),
                      pw.Text('Report No: ${v.id}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text('VIOLATION: ${isOverload ? "PASSENGER OVERLOADING" : "SPEED LIMIT VIOLATION"}',
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                _buildPdfRow('Unit ID', v.unitId),
                _buildPdfRow('Operator', v.operator),
                _buildPdfRow('Route', v.route),
                _buildPdfRow('Location', v.location),
                _buildPdfRow('Date/Time', DateFormat('MMMM dd, yyyy HH:mm').format(v.timestamp)),
                pw.SizedBox(height: 12),
                if (isOverload) ...[
                  _buildPdfRow('Capacity', '${v.details['capacity']} persons'),
                  _buildPdfRow('Actual Passengers', '${v.details['passengers']} persons'),
                  _buildPdfRow('Excess', '${v.details['passengers'] - v.details['capacity']} persons'),
                ] else ...[
                  _buildPdfRow('Speed Limit', '${v.details['limit']} km/h'),
                  _buildPdfRow('Detected Speed', '${v.details['speed']} km/h'),
                  _buildPdfRow('Excess Speed', '${v.details['speed'] - v.details['limit']} km/h'),
                ],
              ],
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}