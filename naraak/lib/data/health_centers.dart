import '../models/health_center_option.dart';

/// Fictional health center / doctor directory for the demo. "Yousif HC
/// (Sitra)" is deliberately given no doctors so the Change Family Doctor
/// flow's "no doctors available at this center" decision point can be
/// demonstrated by picking it.
const List<HealthCenterOption> kHealthCenters = [
  HealthCenterOption(
    name: 'Hoora Health Center',
    doctors: ['Dr. Layla Al-Ansari', 'Dr. Yousif Al-Kooheji'],
  ),
  HealthCenterOption(
    name: 'Naim Health Center',
    doctors: ['Dr. Fatima Buhijji', 'Dr. Ahmed Al-Sayed'],
  ),
  HealthCenterOption(
    name: 'Muharraq Health Center',
    doctors: ['Dr. Layla Al-Ansari', 'Dr. Mariam Al-Doseri'],
  ),
  HealthCenterOption(
    name: 'Bilad Al-Qadeem Health Center',
    doctors: ['Dr. Hassan Al-Ghatam'],
  ),
  HealthCenterOption(
    name: 'Yousif HC (Sitra)',
    doctors: [],
  ),
];
