import '../models/health_center_option.dart';

/// Fictional health center / doctor directory for the demo. "Yousif HC
/// (Sitra)" is deliberately given no doctors so the Change Family Doctor
/// flow's "no doctors available at this center" decision point can be
/// demonstrated by picking it.
const List<HealthCenterOption> kHealthCenters = [
  HealthCenterOption(
    name: 'Hoora Health Center',
    doctors: [
      FamilyDoctorOption(
        doctorId: 'DOC-101',
        name: 'Dr. Layla Al-Ansari',
        gender: 'Female',
        specialty: 'Family Medicine',
        capacityAvailable: true,
        availableQuota: 4,
      ),
      FamilyDoctorOption(
        doctorId: 'DOC-102',
        name: 'Dr. Yousif Al-Kooheji',
        gender: 'Male',
        specialty: 'Family Medicine',
        capacityAvailable: true,
        availableQuota: 3,
      ),
    ],
  ),
  HealthCenterOption(
    name: 'Naim Health Center',
    doctors: [
      FamilyDoctorOption(
        doctorId: 'DOC-103',
        name: 'Dr. Fatima Buhijji',
        gender: 'Female',
        specialty: 'Family Medicine',
        capacityAvailable: true,
        availableQuota: 2,
      ),
      FamilyDoctorOption(
        doctorId: 'DOC-104',
        name: 'Dr. Ahmed Al-Sayed',
        gender: 'Male',
        specialty: 'Family Medicine',
        capacityAvailable: true,
        availableQuota: 5,
      ),
    ],
  ),
  HealthCenterOption(
    name: 'Muharraq Health Center',
    doctors: [
      FamilyDoctorOption(
        doctorId: 'DOC-105',
        name: 'Dr. Layla Al-Ansari',
        gender: 'Female',
        specialty: 'Family Medicine',
        capacityAvailable: true,
        availableQuota: 1,
      ),
      FamilyDoctorOption(
        doctorId: 'DOC-106',
        name: 'Dr. Mariam Al-Doseri',
        gender: 'Female',
        specialty: 'Family Medicine',
        capacityAvailable: false,
        availableQuota: 0,
      ),
    ],
  ),
  HealthCenterOption(
    name: 'Bilad Al-Qadeem Health Center',
    doctors: [
      FamilyDoctorOption(
        doctorId: 'DOC-107',
        name: 'Dr. Hassan Al-Ghatam',
        gender: 'Male',
        specialty: 'Family Medicine',
        capacityAvailable: true,
        availableQuota: 3,
      ),
    ],
  ),
  HealthCenterOption(
    name: 'Yousif HC (Sitra)',
    doctors: [],
  ),
];
