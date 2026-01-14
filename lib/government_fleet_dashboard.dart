import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'constants/app_colors.dart';
import 'models.dart';
import 'dashboard_overview.dart';
import 'violations_management.dart';
import 'history_compliance.dart';
import 'user_management.dart';

// Main Dashboard
class GovernmentFleetDashboard extends StatefulWidget {
  const GovernmentFleetDashboard({super.key});

  @override
  State<GovernmentFleetDashboard> createState() => _GovernmentFleetDashboardState();
}

class _GovernmentFleetDashboardState extends State<GovernmentFleetDashboard> {
  int _currentIndex = 0;
  final MapController _mapController = MapController();
  int _retentionMonths = 6;

  // Mock Data - Mandaue City focused
 // Mock Data - Mandaue City focused
  final List<Violation> _violations = [
    Violation(
      id: 'MAN-2025-001234',
      unitId: 'JE-1234',
      operator: 'ABC Transport Corp',
      route: '04A',
      type: ViolationType.overload,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      location: 'A.S. Fortuna St, Mandaue',
      lat: 10.3235,
      lng: 123.9222,
      status: ViolationStatus.detected,
      details: {'passengers': 28, 'capacity': 18},
      repeatOffenseCount: 5,
    ),
    Violation(
      id: 'MAN-2025-001235',
      unitId: 'JE-5678',
      operator: 'XYZ Transport Inc',
      route: '12B',
      type: ViolationType.overspeed,
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      location: 'M.C. Briones St, Mandaue',
      lat: 10.3312,
      lng: 123.9289,
      status: ViolationStatus.detected,
      details: {'speed': 85, 'limit': 60},
      repeatOffenseCount: 2,
    ),
    Violation(
      id: 'MAN-2025-001236',
      unitId: 'JE-9012',
      operator: 'ABC Transport Corp',
      route: '04A',
      type: ViolationType.overload,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      location: 'UN Avenue, Mandaue',
      lat: 10.3401,
      lng: 123.9345,
      status: ViolationStatus.detected,
      details: {'passengers': 25, 'capacity': 18},
      repeatOffenseCount: 3,
    ),
    Violation(
      id: 'MAN-2025-001237',
      unitId: 'JE-3456',
      operator: 'DEF Transport',
      route: '04B',
      type: ViolationType.overspeed,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
      location: 'Plaridel St, Mandaue',
      lat: 10.3156,
      lng: 123.9178,
      status: ViolationStatus.verified,
      details: {'speed': 92, 'limit': 60},
      repeatOffenseCount: 1,
    ),
    Violation(
      id: 'MAN-2025-001238',
      unitId: 'JE-7890',
      operator: 'GHI Transport',
      route: '13C',
      type: ViolationType.overspeed,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      location: 'Ouano Avenue, Mandaue',
      lat: 10.3445,
      lng: 123.9412,
      status: ViolationStatus.verified,
      details: {'speed': 78, 'limit': 60},
      repeatOffenseCount: 0,
    ),
    Violation(
      id: 'MAN-2025-001239',
      unitId: 'JE-4567',
      operator: 'JKL Transport',
      route: '06D',
      type: ViolationType.overload,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      location: 'S.B. Cabahug St, Mandaue',
      lat: 10.3278,
      lng: 123.9156,
      status: ViolationStatus.resolved,
      details: {'passengers': 22, 'capacity': 18},
      repeatOffenseCount: 0,
      penalty: '500',
      resolvedDate: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Violation(
      id: 'MAN-2025-001240',
      unitId: 'JE-8901',
      operator: 'MNO Transport',
      route: '14A',
      type: ViolationType.overspeed,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      location: 'P. Burgos St, Mandaue',
      lat: 10.3189,
      lng: 123.9245,
      status: ViolationStatus.resolved,
      details: {'speed': 88, 'limit': 60},
      repeatOffenseCount: 1,
      penalty: '1000',
      resolvedDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  List<Violation> get _resolvedViolations => 
      _violations.where((v) => v.status == ViolationStatus.resolved || v.status == ViolationStatus.dismissed).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: _buildAppBar(),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(child: _buildCurrentPage()),
        ],
      ),
    );
  }

PreferredSizeWidget _buildAppBar() {
  return PreferredSize(
    preferredSize: const Size.fromHeight(72),
    child: Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.grey200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Logo - Positioned with absolute positioning for precise control
          Positioned(
            left: -20, // Position it 20px left of the container
            top: -25, // Position it 25px above the header
            bottom: -25, // Extend it 25px below the header
            child: SizedBox(
              height: 120, // Fixed height of 120px
              width: 300, // Fixed width of 300px
              child: Image.asset(
                'assets/bantai.png', // Your logo path
                fit: BoxFit.contain, // Maintain aspect ratio
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'BANT.AI',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 48, // Fallback text size
                        letterSpacing: 2.5,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Main content with padding to avoid overlapping with logo
          Padding(
            padding: const EdgeInsets.only(
              left: 260, // Push content to right to avoid overlapping with logo
              right: 20,
              top: 8,
              bottom: 8,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Removed the SizedBox that was creating space for the old logo
                  
                  // Title section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'TRAFFIC MONITORING',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Real Time Modern Jeepney Operation Analytics and Regulation',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  
                  // Notification and profile
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.grey200, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, size: 24),
                              color: AppColors.grey700,
                              onPressed: () {},
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 9,
                                height: 9,
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.person, color: AppColors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSidebar() {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryDark,
            AppColors.primaryDark.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 28),
          _buildSidebarItem(Icons.dashboard_rounded, 'Dashboard', 0),
          _buildSidebarItem(Icons.warning_amber_rounded, 'Violations Management', 1),
          _buildSidebarItem(Icons.history_rounded, 'History', 2),
          _buildSidebarItem(Icons.settings_rounded, 'User Management', 3),
          const Spacer(),
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.2),
                  AppColors.success.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.success.withOpacity(0.4), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      color: AppColors.success,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'System Status',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'All Systems Operational',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    final isActive = _currentIndex == index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _currentIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isActive ? AppColors.white.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isActive ? AppColors.white.withOpacity(0.2) : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? AppColors.white : AppColors.white.withOpacity(0.7),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? AppColors.white : AppColors.white.withOpacity(0.8),
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onVerifyViolation(Violation violation) {
    setState(() {
      violation.status = ViolationStatus.verified;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Violation ${violation.id} verified successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

 Widget _buildCurrentPage() {
  switch (_currentIndex) {
    case 0:
      return DashboardOverview(
        violations: _violations,
        mapController: _mapController,
        onVerifyViolation: _onVerifyViolation,
      );
    case 1:
      return ViolationsManagement(violations: _violations, onUpdate: () => setState(() {}));
    case 2:
      return HistoryCompliance(
        violations: _resolvedViolations,
        onSetRetentionMonths: (months) {
          setState(() {
            _retentionMonths = months;
          });
        },
      );
    case 3:
      return const UserManagement(); // Changed from SystemSettings()
    default:
      return DashboardOverview(
        violations: _violations,
        mapController: _mapController,
        onVerifyViolation: _onVerifyViolation,
      );
  }
}
}