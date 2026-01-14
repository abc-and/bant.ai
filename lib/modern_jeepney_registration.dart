import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants/app_colors.dart';
import 'models.dart';

class ModernJeepneyRegistration extends StatefulWidget {
  const ModernJeepneyRegistration({super.key});

  @override
  State<ModernJeepneyRegistration> createState() => _ModernJeepneyRegistrationState();
}

class _ModernJeepneyRegistrationState extends State<ModernJeepneyRegistration> {
  final _formKey = GlobalKey<FormState>();
  List<ModernJeepney> _registeredVehicles = [];
  List<ModernJeepney> _filteredVehicles = [];
  
  // Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Active', 'Inactive'];
  
  // Form controllers
  final TextEditingController _vehicleIdController = TextEditingController();
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _vehicleModelController = TextEditingController();
  final TextEditingController _operatorController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _sittingCapacityController = TextEditingController();
  final TextEditingController _standingCapacityController = TextEditingController();
  
  // Editing state
  ModernJeepney? _vehicleToEdit;
  bool _isEditing = false;
  
  String _selectedRoute = '04A';
  
  // Mock routes for Mandaue City
  final List<String> _availableRoutes = [
    '04A', '04B', '04C', '06A', '06B', '06C', '06D',
    '12A', '12B', '13A', '13B', '13C', '14A', '14B',
    '15A', '15B', '16A', '16B', '17A', '17B'
  ];

  @override
  void initState() {
    super.initState();
    _initializeSampleVehicles();
    _searchController.addListener(_filterVehicles);
  }

  @override
  void dispose() {
    _vehicleIdController.dispose();
    _driverNameController.dispose();
    _plateNumberController.dispose();
    _vehicleModelController.dispose();
    _operatorController.dispose();
    _routeController.dispose();
    _sittingCapacityController.dispose();
    _standingCapacityController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initializeSampleVehicles() {
    _registeredVehicles = [
      ModernJeepney(
        vehicleId: 'MPUJ-001',
        driverName: 'Juan Dela Cruz',
        plateNumber: 'JE-1234',
        vehicleType: 'Electric',
        vehicleModel: 'Sarao E-Jeep',
        operator: 'Mandaue Transport Coop',
        route: '04A',
        sittingCapacity: 18,
        standingCapacity: 12,
        registrationDate: DateTime(2024, 1, 15),
        status: 'Active',
        violationCount: 2,
      ),
      ModernJeepney(
        vehicleId: 'MPUJ-002',
        driverName: 'Maria Santos',
        plateNumber: 'JE-5678',
        vehicleType: 'Diesel-Electric Hybrid',
        vehicleModel: 'Toyota Hiace Modernized',
        operator: 'Cebu Jeepney Operators',
        route: '06B',
        sittingCapacity: 15,
        standingCapacity: 10,
        registrationDate: DateTime(2024, 2, 20),
        status: 'Active',
        violationCount: 0,
      ),
      ModernJeepney(
        vehicleId: 'MPUJ-003',
        driverName: 'Pedro Gonzales',
        plateNumber: 'JE-9101',
        vehicleType: 'Euro 4 Compliant',
        vehicleModel: 'Isuzu Modern Jeepney',
        operator: 'Metro Cebu Transport',
        route: '13A',
        sittingCapacity: 20,
        standingCapacity: 8,
        registrationDate: DateTime(2024, 3, 10),
        status: 'Inactive',
        violationCount: 1,
      ),
      ModernJeepney(
        vehicleId: 'MPUJ-004',
        driverName: 'Ana Reyes',
        plateNumber: 'JE-1121',
        vehicleType: 'Air-Conditioned',
        vehicleModel: 'Mitsubishi Modern PUJ',
        operator: 'Cebu City Transport',
        route: '15B',
        sittingCapacity: 22,
        standingCapacity: 10,
        registrationDate: DateTime(2024, 1, 25),
        status: 'Active',
        violationCount: 3,
      ),
      ModernJeepney(
        vehicleId: 'MPUJ-005',
        driverName: 'Carlos Lim',
        plateNumber: 'JE-3141',
        vehicleType: 'Standard Modern',
        vehicleModel: 'Foton Modern Jeepney',
        operator: 'Southern Cebu Transport',
        route: '12A',
        sittingCapacity: 16,
        standingCapacity: 10,
        registrationDate: DateTime(2024, 2, 5),
        status: 'Inactive',
        violationCount: 0,
      ),
    ];
    _filteredVehicles = List.from(_registeredVehicles);
  }

  void _filterVehicles() {
    final searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _filteredVehicles = _registeredVehicles.where((vehicle) {
        final matchesSearch = searchQuery.isEmpty ||
            vehicle.vehicleId.toLowerCase().contains(searchQuery) ||
            vehicle.driverName.toLowerCase().contains(searchQuery) ||
            vehicle.plateNumber.toLowerCase().contains(searchQuery) ||
            vehicle.vehicleModel.toLowerCase().contains(searchQuery);
        
        final matchesFilter = _selectedFilter == 'All' ||
            (_selectedFilter == 'Active' && vehicle.status == 'Active') ||
            (_selectedFilter == 'Inactive' && vehicle.status == 'Inactive');
        
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _registerOrUpdateVehicle() {
    if (_formKey.currentState!.validate()) {
      final sitting = int.parse(_sittingCapacityController.text);
      final standing = int.parse(_standingCapacityController.text);

      if (_isEditing && _vehicleToEdit != null) {
        // Update existing vehicle
        setState(() {
          final index = _registeredVehicles.indexOf(_vehicleToEdit!);
          _registeredVehicles[index] = ModernJeepney(
            vehicleId: _vehicleIdController.text,
            driverName: _driverNameController.text,
            plateNumber: _plateNumberController.text,
            vehicleType: _registeredVehicles[index].vehicleType,
            vehicleModel: _vehicleModelController.text,
            operator: _operatorController.text,
            route: _selectedRoute,
            sittingCapacity: sitting,
            standingCapacity: standing,
            registrationDate: _registeredVehicles[index].registrationDate,
            status: _registeredVehicles[index].status,
            violationCount: _registeredVehicles[index].violationCount,
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_vehicleIdController.text} updated successfully'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        // Register new vehicle
        final newVehicle = ModernJeepney(
          vehicleId: _vehicleIdController.text,
          driverName: _driverNameController.text,
          plateNumber: _plateNumberController.text,
          vehicleType: 'Electric',
          vehicleModel: _vehicleModelController.text,
          operator: _operatorController.text,
          route: _selectedRoute,
          sittingCapacity: sitting,
          standingCapacity: standing,
          registrationDate: DateTime.now(),
          status: 'Active',
          violationCount: 0,
        );
        
        setState(() {
          _registeredVehicles.insert(0, newVehicle);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_vehicleIdController.text} registered successfully'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      _clearForm();
      _filterVehicles();
    }
  }

  void _startEditVehicle(ModernJeepney vehicle) {
    setState(() {
      _isEditing = true;
      _vehicleToEdit = vehicle;
      _vehicleIdController.text = vehicle.vehicleId;
      _driverNameController.text = vehicle.driverName;
      _plateNumberController.text = vehicle.plateNumber;
      _vehicleModelController.text = vehicle.vehicleModel;
      _operatorController.text = vehicle.operator;
      _selectedRoute = vehicle.route;
      _sittingCapacityController.text = vehicle.sittingCapacity.toString();
      _standingCapacityController.text = vehicle.standingCapacity.toString();
    });
    
    // Scroll to form
    Future.delayed(Duration.zero, () {
      Scrollable.ensureVisible(_formKey.currentContext!);
    });
  }

  void _toggleVehicleStatus(ModernJeepney vehicle) {
    setState(() {
      final index = _registeredVehicles.indexOf(vehicle);
      _registeredVehicles[index] = ModernJeepney(
        vehicleId: vehicle.vehicleId,
        driverName: vehicle.driverName,
        plateNumber: vehicle.plateNumber,
        vehicleType: vehicle.vehicleType,
        vehicleModel: vehicle.vehicleModel,
        operator: vehicle.operator,
        route: vehicle.route,
        sittingCapacity: vehicle.sittingCapacity,
        standingCapacity: vehicle.standingCapacity,
        registrationDate: vehicle.registrationDate,
        status: vehicle.status == 'Active' ? 'Inactive' : 'Active',
        violationCount: vehicle.violationCount,
      );
    });
    _filterVehicles();
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _vehicleIdController.clear();
    _driverNameController.clear();
    _plateNumberController.clear();
    _vehicleModelController.clear();
    _operatorController.clear();
    _routeController.clear();
    _sittingCapacityController.clear();
    _standingCapacityController.clear();
    _selectedRoute = '04A';
    _isEditing = false;
    _vehicleToEdit = null;
    setState(() {});
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.grey300, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.grey300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.error, width: 1.5),
            ),
            counterText: '',
          ),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.grey300, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down_rounded, color: AppColors.grey600),
              iconSize: 28,
              elevation: 8,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildVehicleCard(ModernJeepney vehicle) {
    final totalCapacity = vehicle.sittingCapacity + vehicle.standingCapacity;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Vehicle Icon/Status with click to toggle
            GestureDetector(
              onTap: () => _toggleVehicleStatus(vehicle),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: vehicle.status == 'Active'
                      ? LinearGradient(
                          colors: [AppColors.success, AppColors.successLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [AppColors.warning, AppColors.warning.withOpacity(0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.directions_bus_rounded,
                  color: AppColors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 18),
            
            // Vehicle Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.vehicleId, // Show Vehicle ID as main title
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryLight, width: 1),
                        ),
                        child: Text(
                          vehicle.vehicleModel, // Vehicle Model in blue badge
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: vehicle.status == 'Active'
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          vehicle.status,
                          style: TextStyle(
                            color: vehicle.status == 'Active'
                                ? AppColors.success
                                : AppColors.warning,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Plate: ${vehicle.plateNumber} | Route: ${vehicle.route} | Type: ${vehicle.vehicleType}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        const TextSpan(text: 'Driver: '),
                        TextSpan(
                          text: vehicle.driverName,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' • Operator: '),
                        TextSpan(
                          text: vehicle.operator,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' • Capacity: '),
                        TextSpan(
                          text: '${vehicle.sittingCapacity} sitting, ${vehicle.standingCapacity} standing',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.grey500,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Total: $totalCapacity passengers • Registered: ${_formatDate(vehicle.registrationDate)} • Violations: ${vehicle.violationCount}',
                          style: TextStyle(
                            color: AppColors.grey500,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Edit Button
            IconButton(
              onPressed: () => _startEditVehicle(vehicle),
              icon: Icon(
                Icons.edit_rounded,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey200, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    subtitle,
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = _registeredVehicles.where((v) => v.status == 'Active').length;
    final inactiveCount = _registeredVehicles.where((v) => v.status == 'Inactive').length;

    return Scaffold(
      backgroundColor: AppColors.grey50,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Registration Form - Fixed height container
            Expanded(
              flex: 2,
              child: Container(
                height: MediaQuery.of(context).size.height - 48,
                child: SingleChildScrollView(
                  child: Container(
                    key: _formKey,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.grey200, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.03),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: _isEditing
                                    ? LinearGradient(
                                        colors: [AppColors.warning, AppColors.error],
                                      )
                                    : AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _isEditing ? Icons.edit_rounded : Icons.app_registration_rounded,
                                color: AppColors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditing ? 'Edit Jeepney' : 'Register New Jeepney',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _isEditing
                                        ? 'Update the details of this registered jeepney'
                                        : 'Complete the form to add a modernized jeepney to the fleet',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Divider(color: AppColors.grey200, height: 1),
                        const SizedBox(height: 24),
                        
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Row 1: Vehicle ID and Driver Name
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField(
                                      label: "Vehicle's ID",
                                      controller: _vehicleIdController,
                                      hint: "Enter vehicle id",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vehicle ID is required';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\-]')),
                                      ],
                                      maxLength: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildInputField(
                                      label: "Driver's Name",
                                      controller: _driverNameController,
                                      hint: "Enter driver's name",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Driver's name is required";
                                        }
                                        if (value.length < 3) {
                                          return 'Name must be at least 3 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Row 2: Plate Number and Route
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField(
                                      label: "Plate Number",
                                      controller: _plateNumberController,
                                      hint: "Enter plate number",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Plate number is required';
                                        }
                                        if (!RegExp(r'^[A-Z]{2}-\d{4}$').hasMatch(value)) {
                                          return 'Format: XX-1234 (e.g., JE-1234)';
                                        }
                                        return null;
                                      },
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9-]')),
                                        UpperCaseTextFormatter(),
                                      ],
                                      maxLength: 7,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: "Route",
                                      value: _selectedRoute,
                                      items: _availableRoutes,
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedRoute = value!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Row 3: Vehicle Model and Operator
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField(
                                      label: "Vehicle Model",
                                      controller: _vehicleModelController,
                                      hint: "Enter vehicle model",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Vehicle model is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildInputField(
                                      label: "Operator",
                                      controller: _operatorController,
                                      hint: "Enter operator",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Operator name is required';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Row 4: Sitting and Standing Capacity
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField(
                                      label: "Sitting Capacity",
                                      controller: _sittingCapacityController,
                                      hint: "Enter sitting capacity",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Sitting capacity is required';
                                        }
                                        final capacity = int.tryParse(value);
                                        if (capacity == null || capacity <= 0) {
                                          return 'Enter valid number';
                                        }
                                        if (capacity > 30) {
                                          return 'Maximum sitting capacity is 30';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      maxLength: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: _buildInputField(
                                      label: "Standing Capacity",
                                      controller: _standingCapacityController,
                                      hint: "Enter standing capacity",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Standing capacity is required';
                                        }
                                        final capacity = int.tryParse(value);
                                        if (capacity == null || capacity < 0) {
                                          return 'Enter valid number';
                                        }
                                        if (capacity > 20) {
                                          return 'Maximum standing capacity is 20';
                                        }
                                        return null;
                                      },
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      maxLength: 2,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _registerOrUpdateVehicle,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isEditing ? AppColors.warning : AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(_isEditing ? Icons.update_rounded : Icons.check_circle_outline_rounded, size: 20),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isEditing ? 'UPDATE VEHICLE' : 'REGISTER VEHICLE',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 120,
                              child: OutlinedButton(
                                onPressed: _clearForm,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: AppColors.grey400, width: 1.5),
                                ),
                                child: Text(
                                  _isEditing ? 'CANCEL' : 'CLEAR',
                                  style: TextStyle(
                                    color: AppColors.grey600,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 24),
            
            // Registered Vehicles List with Statistics
            Expanded(
              flex: 3,
              child: Container(
                height: MediaQuery.of(context).size.height - 48,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Vehicles List Container
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.grey200, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Registered Jeepneys',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${_filteredVehicles.length} vehicles shown (${_registeredVehicles.length} total)',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: AppColors.primaryGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.file_download_outlined,
                                        color: AppColors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Export Data',
                                        style: TextStyle(
                                          color: AppColors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            // Search and Filter Bar
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.grey50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.grey200, width: 1),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.grey300, width: 1),
                                      ),
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 16),
                                            child: Icon(
                                              Icons.search_rounded,
                                              color: AppColors.grey500,
                                              size: 20,
                                            ),
                                          ),
                                          Expanded(
                                            child: TextField(
                                              controller: _searchController,
                                              decoration: InputDecoration(
                                                hintText: 'Search by ID, driver, plate, or model...',
                                                border: InputBorder.none,
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                                isDense: true,
                                              ),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          if (_searchController.text.isNotEmpty)
                                            IconButton(
                                              icon: Icon(Icons.clear_rounded, size: 18, color: AppColors.grey500),
                                              onPressed: () {
                                                _searchController.clear();
                                                _filterVehicles();
                                              },
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 150,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.grey300, width: 1),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedFilter,
                                        isExpanded: true,
                                        icon: Icon(Icons.filter_alt_rounded, color: AppColors.primary, size: 20),
                                        style: TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedFilter = value!;
                                          });
                                          _filterVehicles();
                                        },
                                        items: _filterOptions.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text('Filter: $value'),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Vehicles List
                            if (_filteredVehicles.isEmpty)
                              Container(
                                height: 200,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 64,
                                        color: AppColors.grey400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No vehicles found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your search or filter',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ..._filteredVehicles.map(_buildVehicleCard).toList(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Statistics Cards
                      Row(
                        children: [
                          _buildStatsCard(
                            title: 'Active Vehicles',
                            value: '$activeCount',
                            subtitle: 'On Route',
                            color: AppColors.success,
                            icon: Icons.check_circle_rounded,
                          ),
                          const SizedBox(width: 12),
                          _buildStatsCard(
                            title: 'Inactive Vehicles',
                            value: '$inactiveCount',
                            subtitle: 'Maintenance',
                            color: AppColors.warning,
                            icon: Icons.pause_circle_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}