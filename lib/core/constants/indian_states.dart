/// Complete mapping of Indian states and Union Territories to their
/// 2-letter Zoho/GST state codes.
const Map<String, String> indianStateNameToCode = {
  'Andaman and Nicobar Islands': 'AN',
  'Andhra Pradesh': 'AP',
  'Arunachal Pradesh': 'AR',
  'Assam': 'AS',
  'Bihar': 'BR',
  'Chandigarh': 'CH',
  'Chhattisgarh': 'CG',
  'Dadra and Nagar Haveli and Daman and Diu': 'DD',
  'Delhi': 'DL',
  'Goa': 'GA',
  'Gujarat': 'GJ',
  'Haryana': 'HR',
  'Himachal Pradesh': 'HP',
  'Jammu and Kashmir': 'JK',
  'Jharkhand': 'JH',
  'Karnataka': 'KA',
  'Kerala': 'KL',
  'Ladakh': 'LA',
  'Lakshadweep': 'LD',
  'Madhya Pradesh': 'MP',
  'Maharashtra': 'MH',
  'Manipur': 'MN',
  'Meghalaya': 'ML',
  'Mizoram': 'MZ',
  'Nagaland': 'NL',
  'Odisha': 'OD',
  'Puducherry': 'PY',
  'Punjab': 'PB',
  'Rajasthan': 'RJ',
  'Sikkim': 'SK',
  'Tamil Nadu': 'TN',
  'Telangana': 'TG',
  'Tripura': 'TR',
  'Uttar Pradesh': 'UP',
  'Uttarakhand': 'UK',
  'West Bengal': 'WB',
};

/// Reverse mapping: state code → state name
final Map<String, String> indianStateCodeToName = {
  for (final entry in indianStateNameToCode.entries) entry.value: entry.key,
};

/// Sorted list of all Indian state names (for dropdowns)
final List<String> indianStateNames = indianStateNameToCode.keys.toList()
  ..sort();

/// Get state code from state name (case-insensitive match)
String? getStateCode(String stateName) {
  final lower = stateName.toLowerCase();
  for (final entry in indianStateNameToCode.entries) {
    if (entry.key.toLowerCase() == lower) return entry.value;
  }
  return null;
}

/// Get state name from state code
String? getStateName(String stateCode) {
  return indianStateCodeToName[stateCode.toUpperCase()];
}
