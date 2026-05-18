class Dtc {
  final String code;
  final String description;
  final DtcStatus status;

  Dtc({required this.code, required this.description, required this.status});
}

enum DtcStatus {
  stored,
  pending,
  permanent,
}

class DtcService {
  static String lookupDescription(String code) {
    // Basic SAE generic lookups
    final Map<String, String> commonCodes = {
      'P0171': 'System Too Lean (Bank 1)',
      'P0300': 'Random or Multiple Cylinder Misfire Detected',
      'P0420': 'Catalyst System Efficiency Below Threshold (Bank 1)',
    };
    return commonCodes[code] ?? 'Unknown Diagnostic Trouble Code';
  }
}
