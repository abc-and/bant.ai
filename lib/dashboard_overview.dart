import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'constants/app_colors.dart';
import 'models.dart';

class DashboardOverview extends StatefulWidget {
  final List<Violation> violations;
  final MapController mapController;
  final Function(Violation) onVerifyViolation;

  const DashboardOverview({
    super.key,
    required this.violations,
    required this.mapController,
    required this.onVerifyViolation,
  });

  @override
  State<DashboardOverview> createState() => _DashboardOverviewState();
}

class _DashboardOverviewState extends State<DashboardOverview> {
  String _timeFilter = 'Today';
  bool _showOverloading = true;
  bool _showOverspeeding = true;

  @override
  Widget build(BuildContext context) {
    final unverifiedViolations = widget.violations
        .where((v) => v.status == ViolationStatus.detected)
        .toList();
    
    final filteredViolations = unverifiedViolations.where((v) {
      if (!_showOverloading && v.type == ViolationType.overload) return false;
      if (!_showOverspeeding && v.type == ViolationType.overspeed) return false;
      return true;
    }).toList();

    final overload = unverifiedViolations
        .where((v) => v.type == ViolationType.overload)
        .length;
    final overspeed = unverifiedViolations
        .where((v) => v.type == ViolationType.overspeed)
        .length;
    final activeVehicles = 142;
    final totalAlerts = unverifiedViolations.length;

    return Column(
      children: [
        // Top Control Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(bottom: BorderSide(color: AppColors.grey200)),
          ),
          child: Row(
            children: [
              // Time Filter Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.grey300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _timeFilter,
                    items: ['Today', 'This Week', 'This Month']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: const TextStyle(fontSize: 14)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _timeFilter = v!),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Overloading Toggle
              _buildToggleChip(
                'Overloading',
                _showOverloading,
                AppColors.error,
                (val) => setState(() => _showOverloading = val),
              ),
              const SizedBox(width: 12),
              
              // Overspeeding Toggle
              _buildToggleChip(
                'Overspeeding',
                _showOverspeeding,
                AppColors.primary,
                (val) => setState(() => _showOverspeeding = val),
              ),
              
              const Spacer(),
              
              // Live Vehicle Monitoring Label
              Text(
                'Live Vehicle Monitoring',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        
        // Main Content
        Expanded(
          child: Row(
            children: [
              // Map Section
              Expanded(
                flex: 7,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: widget.mapController,
                          options: const MapOptions(
                            initialCenter: LatLng(10.3235, 123.9222),
                            initialZoom: 13.0,
                            maxZoom: 18.0,
                            minZoom: 6.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.mandaue.bantai',
                            ),
                            MarkerLayer(
                              markers: filteredViolations.map((v) {
                                return Marker(
                                  point: LatLng(v.lat, v.lng),
                                  width: 50,
                                  height: 50,
                                  child: GestureDetector(
                                    onTap: () => _showQuickView(context, v),
                                    child: Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: v.type == ViolationType.overload
                                            ? AppColors.error
                                            : AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.black.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        v.type == ViolationType.overload
                                            ? Icons.people
                                            : Icons.speed,
                                        color: AppColors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        
                        // Map Legend
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Map Legend',
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildLegendItem(AppColors.error, 'Overloading'),
                                const SizedBox(height: 8),
                                _buildLegendItem(AppColors.primary, 'Overspeeding'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Right Info Panel
              Container(
                width: 380,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(left: BorderSide(color: AppColors.grey200)),
                ),
                child: Column(
                  children: [
                    // Stats Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.grey50,
                        border: Border(bottom: BorderSide(color: AppColors.grey200)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatBox(
                                  Icons.directions_bus,
                                  '$activeVehicles',
                                  'Active Vehicles',
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatBox(
                                  Icons.warning_amber,
                                  '$totalAlerts',
                                  'Alerts Today',
                                  AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatBox(
                                  Icons.calendar_today,
                                  DateFormat('MM/dd/yy').format(DateTime.now()),
                                  'Date',
                                  AppColors.grey600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatBox(
                                  Icons.access_time,
                                  DateFormat('HH:mm:ss').format(DateTime.now()),
                                  'Time',
                                  AppColors.grey600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Recent Alerts Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border(bottom: BorderSide(color: AppColors.grey200)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.notifications_active, color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Recent Alerts',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (filteredViolations.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${filteredViolations.length} New',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Alerts List
                    Expanded(
                      child: filteredViolations.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 56,
                                    color: AppColors.success.withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No alerts',
                                    style: TextStyle(
                                      color: AppColors.grey600,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'All violations verified',
                                    style: TextStyle(
                                      color: AppColors.grey500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredViolations.length,
                              itemBuilder: (context, index) {
                                final v = filteredViolations[index];
                                return _buildAlertCard(context, v);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleChip(
    String label,
    bool isActive,
    Color color,
    Function(bool) onChanged,
  ) {
    return InkWell(
      onTap: () => onChanged(!isActive),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : AppColors.grey50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? color.withOpacity(0.5) : AppColors.grey300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.circle_outlined,
              color: isActive ? color : AppColors.grey400,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : AppColors.grey600,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.grey700,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppColors.grey600,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(BuildContext context, Violation v) {
    final isOverload = v.type == ViolationType.overload;
    final timeAgo = _getTimeAgo(v.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverload
              ? AppColors.error.withOpacity(0.3)
              : AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey300.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isOverload ? AppColors.error : AppColors.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isOverload ? Icons.people : Icons.speed,
                    color: isOverload ? AppColors.error : AppColors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${v.unitId} • ${v.route}',
                        style: TextStyle(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        v.location,
                        style: TextStyle(
                          color: AppColors.grey600,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOverload
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isOverload ? 'Overload' : 'Overspeed',
                    style: TextStyle(
                      color: isOverload ? AppColors.error : AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isOverload
                      ? '${v.details['passengers']}/${v.details['capacity']} passengers'
                      : '${v.details['speed']} kph',
                  style: TextStyle(
                    color: AppColors.grey600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: AppColors.grey500,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showVerificationDialog(context, v),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Review',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationDialog(BuildContext context, Violation v) {
    final isOverload = v.type == ViolationType.overload;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.verified_user, color: AppColors.primary),
            const SizedBox(width: 12),
            const Text('Verify Violation'),
          ],
        ),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Evidence Photo - Only for overloading
                if (isOverload) ...[
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey300),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_camera, size: 48, color: AppColors.grey400),
                          const SizedBox(height: 8),
                          Text(
                            'Evidence Photo',
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Captured: ${DateFormat('MM/dd/yy HH:mm').format(v.timestamp)}',
                            style: TextStyle(
                              color: AppColors.grey500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Text(
                  'Violation Details',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildVerificationRow('Violation ID', v.id),
                _buildVerificationRow('Unit ID', v.unitId),
                _buildVerificationRow('Operator', v.operator),
                _buildVerificationRow('Route', v.route),
                _buildVerificationRow('Location', v.location),
                _buildVerificationRow(
                  'Type',
                  v.type == ViolationType.overload ? 'Overloading' : 'Overspeeding',
                ),
                if (v.type == ViolationType.overload)
                  _buildVerificationRow(
                    'Passengers',
                    '${v.details['passengers']}/${v.details['capacity']} (Excess: ${v.details['passengers'] - v.details['capacity']})',
                  )
                else
                  _buildVerificationRow(
                    'Speed',
                    '${v.details['speed']} kph (Limit: ${v.details['limit']} kph, Excess: ${v.details['speed'] - v.details['limit']} kph)',
                  ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.warning),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Review all evidence before verification. Once verified, this violation will be moved to Violations Management.',
                          style: TextStyle(
                            color: AppColors.grey700,
                            fontSize: 13,
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
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              widget.onVerifyViolation(v);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.check, color: AppColors.white),
            label: const Text('Verify', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickView(BuildContext context, Violation v) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${v.unitId} - ${v.location}'),
        action: SnackBarAction(
          label: 'VERIFY',
          onPressed: () => _showVerificationDialog(context, v),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}