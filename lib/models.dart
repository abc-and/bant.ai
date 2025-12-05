// Models
enum ViolationType { overload, overspeed }
enum ViolationStatus { detected, verified, forSCO, scoIssued, resolved, dismissed }

class Violation {
  final String id;
  final String unitId;
  final String operator;
  final String route;
  final ViolationType type;
  final DateTime timestamp;
  final String location;
  final double lat;
  final double lng;
  ViolationStatus status;
  final Map<String, dynamic> details;
  String? assignedOfficer;
  int repeatOffenseCount;
  String? penalty;
  DateTime? resolvedDate;

  Violation({
    required this.id,
    required this.unitId,
    required this.operator,
    required this.route,
    required this.type,
    required this.timestamp,
    required this.location,
    required this.lat,
    required this.lng,
    required this.status,
    required this.details,
    this.assignedOfficer,
    this.repeatOffenseCount = 0,
    this.penalty,
    this.resolvedDate,
  });
}