import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final List<String> _dateFilters = ['Today', 'Last 7 days', 'Last 30 days', 'Custom'];
  String _selectedDateFilter = 'Today';
  bool _showOverloading = true;
  bool _showOverspeeding = true;
  
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];

  // Mock data for demonstration
  final List<Map<String, dynamic>> _alerts = [
    {
      'type': 'overload',
      'vehicle': 'JEEP-001',
      'location': 'Quezon City',
      'passengers': 25,
      'capacity': 18,
      'time': '14:30',
      'status': 'pending',
      'lat': 14.6760,
      'lng': 121.0437,
    },
    {
      'type': 'overspeed',
      'vehicle': 'JEEP-002',
      'location': 'Manila',
      'speed': 75,
      'limit': 60,
      'time': '15:45',
      'status': 'pending',
      'lat': 14.5995,
      'lng': 120.9842,
    },
    {
      'type': 'overload',
      'vehicle': 'JEEP-003',
      'location': 'Makati',
      'passengers': 22,
      'capacity': 18,
      'time': '16:20',
      'status': 'reviewed',
      'lat': 14.5547,
      'lng': 121.0244,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

void _initializeMarkers() {
  _markers.clear();
  for (var alert in _alerts) {
    _markers.add(
      Marker(
        point: LatLng(alert['lat'], alert['lng']),
        child: GestureDetector(
          onTap: () => _showIncidentDetails(alert),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: alert['type'] == 'overload' ? Colors.red : Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              alert['type'] == 'overload' ? Icons.people : Icons.speed,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

  void _showIncidentDetails(Map<String, dynamic> alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              alert['type'] == 'overload' ? Icons.people : Icons.speed,
              color: alert['type'] == 'overload' ? Colors.red : Colors.blue,
            ),
            const SizedBox(width: 8),
            Text('Incident Details - ${alert['vehicle']}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Vehicle', alert['vehicle']),
            _buildDetailRow('Location', alert['location']),
            _buildDetailRow('Time', alert['time']),
            if (alert['type'] == 'overload') ...[
              _buildDetailRow('Passengers', '${alert['passengers']}/${alert['capacity']}'),
              _buildDetailRow('Status', 'Overloaded by ${alert['passengers'] - alert['capacity']} passengers'),
            ] else ...[
              _buildDetailRow('Speed', '${alert['speed']} kph'),
              _buildDetailRow('Speed Limit', '${alert['limit']} kph'),
              _buildDetailRow('Status', 'Overspeeding by ${alert['speed'] - alert['limit']} kph'),
            ],
            const SizedBox(height: 16),
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.photo, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Evidence Image',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          if (alert['status'] == 'pending') ...[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dismiss'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle review action
                Navigator.pop(context);
                _showReviewSuccess(alert);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: alert['type'] == 'overload' ? Colors.red : Colors.blue,
              ),
              child: const Text('Review Incident', style: TextStyle(color: Colors.white)),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
        ],
      ),
    );
  }

  void _showReviewSuccess(Map<String, dynamic> alert) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Incident ${alert['vehicle']} marked as reviewed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'BANT.AI',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Traffic Monitoring Dashboard',
              style: TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.blue[50],
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.blue[700]),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.account_circle, color: Colors.blue[700]),
            onPressed: () {},
          ),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue[900]!.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildSidebarItem(Icons.dashboard, 'Dashboard', 0),
                _buildSidebarItem(Icons.history, 'History', 1),
                _buildSidebarItem(Icons.settings, 'Settings', 2),
                const Spacer(),
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'System Status',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'All Systems Operational',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Header with Filters
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Date Filter
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDateFilter,
                            icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedDateFilter = newValue!;
                              });
                            },
                            items: _dateFilters.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.blue[700]),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      // Alert Type Filters
                      Row(
                        children: [
                          FilterChip(
                            label: const Text('Overloading'),
                            selected: _showOverloading,
                            onSelected: (bool value) {
                              setState(() {
                                _showOverloading = value;
                              });
                            },
                            selectedColor: Colors.red[100],
                            checkmarkColor: Colors.red,
                            labelStyle: TextStyle(
                              color: _showOverloading ? Colors.red : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Overspeeding'),
                            selected: _showOverspeeding,
                            onSelected: (bool value) {
                              setState(() {
                                _showOverspeeding = value;
                              });
                            },
                            selectedColor: Colors.blue[100],
                            checkmarkColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: _showOverspeeding ? Colors.blue : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'Live Fleet Monitoring',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Main Content Area
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column - Map
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue[100]!,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              children: [
                                // OSM Map
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    center: const LatLng(14.5995, 120.9842), // Manila coordinates
                                    zoom: 11.0,
                                    maxZoom: 18.0,
                                    minZoom: 6.0,
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.example.bantai',
                                    ),
                                    MarkerLayer(markers: _markers),
                                  ],
                                ),
                                
                                // Map Controls
                                Positioned(
                                  top: 16,
                                  right: 16,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.add, color: Colors.blue[700]),
                                          onPressed: () {
                                            _mapController.move(
                                              _mapController.camera.center,
                                              _mapController.camera.zoom + 1,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.remove, color: Colors.blue[700]),
                                          onPressed: () {
                                            _mapController.move(
                                              _mapController.camera.center,
                                              _mapController.camera.zoom - 1,
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.my_location, color: Colors.blue[700]),
                                          onPressed: () {
                                            _mapController.move(
                                              const LatLng(14.5995, 120.9842),
                                              11.0,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Map Legend
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Map Legend',
                                          style: TextStyle(
                                            color: Colors.blue[800],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        _buildLegendItem(Colors.red, 'Overloading'),
                                        _buildLegendItem(Colors.blue, 'Overspeeding'),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Right Column - Alerts and Stats
                      Container(
                        width: 350,
                        margin: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Statistics Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Active Vehicles',
                                    '142',
                                    Icons.directions_bus,
                                    Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    'Alerts Today',
                                    '23',
                                    Icons.warning,
                                    Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    'Avg Speed',
                                    '45 kph',
                                    Icons.speed,
                                    Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildStatCard(
                                    'Response Time',
                                    '2.3 min',
                                    Icons.timer,
                                    Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Recent Alerts
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Icon(Icons.notifications_active, color: Colors.red[700]),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Recent Alerts',
                                            style: TextStyle(
                                              color: Colors.blue[800],
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.red[50],
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${_alerts.where((alert) => alert['status'] == 'pending').length} New',
                                              style: TextStyle(
                                                color: Colors.red[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: _alerts.length,
                                        itemBuilder: (context, index) {
                                          final alert = _alerts[index];
                                          return _buildAlertItem(alert);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _currentIndex == index ? Colors.white.withOpacity(0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    final isOverload = alert['type'] == 'overload';
    final isPending = alert['status'] == 'pending';
    
    return GestureDetector(
      onTap: () => _showIncidentDetails(alert),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isPending ? (isOverload ? Colors.red[50] : Colors.blue[50]) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPending ? (isOverload ? Colors.red[100]! : Colors.blue[100]!) : Colors.grey[200]!,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 40,
              decoration: BoxDecoration(
                color: isOverload ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${alert['vehicle']} • ${alert['location']}',
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOverload 
                      ? 'Overload: ${alert['passengers']}/${alert['capacity']} passengers'
                      : 'Overspeed: ${alert['speed']} kph (Limit: ${alert['limit']} kph)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Time: ${alert['time']}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isPending)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isOverload ? Colors.red : Colors.blue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Review',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}