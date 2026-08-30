/// Naraak Phase 5 Dummy API

class NaraakApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  const NaraakApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'NaraakApiException($statusCode, $code): $message';
}

class NaraakDummyApi {
  NaraakDummyApi({this.simulatedDelay = const Duration(milliseconds: 250)});

  final Duration simulatedDelay;

  // Endpoint constants are documentation helpers only. No network is used.
  static const String appointmentsEndpoint = '/api/v1/appointments';
  static const String vaccinationsEndpoint = '/api/v1/vaccinations/{patientId}';
  static const String reportsEndpoint = '/api/v1/reports/{patientId}';
  static const String newbornCardEndpoint = '/api/v1/newborn-card';
  static const String hajjEndpoint = '/api/v1/hajj-certificate';
  static const String addressEndpoint = '/api/v1/address';
  static const String feeExemptionEndpoint = '/api/v1/fee-exemption';
  static const String mobileUnitEndpoint = '/api/v1/mobile-unit';
  static const String mammogramEndpoint = '/api/v1/mammogram';
  static const String familyDoctorEndpoint = '/api/v1/family-doctor/change';
  static const String researchEndpoint = '/api/v1/research-application';
  static const String profileEndpoint = '/api/v1/profile';
  static const String authEndpoint = '/api/v1/auth/ekey';

  Future<void> _wait() => Future<void>.delayed(simulatedDelay);

  Map<String, dynamic> _success(dynamic data) => {
        'status': 'success',
        'data': data,
        'error': null,
      };

  // -----------------------------
  // Dummy data
  // -----------------------------

  final Map<String, dynamic> _patient = {
    'patientId': 'PAT-001',
    'cpr': '990101321',
    'fullName': 'Mariam Abdulla',
    'age': 27,
    'gender': 'Female',
    'phone': '+973 39124567',
    'email': 'mariam.abdulla@example.com',
    'language': 'ar',
    'bloodType': 'O+',
    'nationality': 'Bahraini',
    'cprExpiryDate': '2028-01-15',
    'healthCenter': {
      'id': 'HC-001',
      'name': 'Naim Health Center',
    },
    'familyDoctor': {
      'doctorId': 'DOC-001',
      'doctorName': 'Dr. Noor Al Khalifa',
      'gender': 'Female',
      'specialty': 'Family Medicine',
    },
  };

  final List<Map<String, dynamic>> _familyMembers = [
    {
      'familyMemberId': 'FAM-001',
      'patientId': 'PAT-002',
      'fullName': 'Yousef Abdulla',
      'age': 8,
      'cpr': '180512147',
      'phone': '+973 33657842',
      'email': 'yousef.abdulla@example.com',
      'relationship': 'Son',
      'consentStatus': 'verified',
      'healthCenterId': 'HC-001',
    },
  ];

  final List<Map<String, dynamic>> _slots = [
    {
      'slotId': 'SLOT-001',
      'doctorId': 'DOC-001',
      'doctorName': 'Dr. Noor Al Khalifa',
      'doctorGender': 'Female',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'General Clinic',
      'date': '2026-09-01',
      'startTime': '09:00',
      'endTime': '09:20',
      'appointmentType': 'in-center',
      'available': false,
    },
    {
      'slotId': 'SLOT-002',
      'doctorId': 'DOC-002',
      'doctorName': 'Dr. Layla Hassan',
      'doctorGender': 'Female',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'General Clinic',
      'date': '2026-09-01',
      'startTime': '10:20',
      'endTime': '10:40',
      'appointmentType': 'in-center',
      'available': true,
    },
    {
      'slotId': 'SLOT-003',
      'doctorId': 'DOC-003',
      'doctorName': 'Dr. Ahmed Salman',
      'doctorGender': 'Male',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'General Clinic',
      'date': '2026-09-02',
      'startTime': '11:00',
      'endTime': '11:20',
      'appointmentType': 'tele',
      'available': false,
    },
    {
      'slotId': 'SLOT-004',
      'doctorId': 'DOC-002',
      'doctorName': 'Dr. Layla Hassan',
      'doctorGender': 'Female',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'General Clinic',
      'date': '2026-09-03',
      'startTime': '08:40',
      'endTime': '09:00',
      'appointmentType': 'in-center',
      'available': true,
    },
    {
      'slotId': 'SLOT-005',
      'doctorId': 'DOC-003',
      'doctorName': 'Dr. Ahmed Salman',
      'doctorGender': 'Male',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'General Clinic',
      'date': '2026-09-03',
      'startTime': '12:00',
      'endTime': '12:20',
      'appointmentType': 'tele',
      'available': true,
    },
    {
      'slotId': 'SLOT-006',
      'doctorId': 'DOC-006',
      'doctorName': 'Dr. Sara Mahmood',
      'doctorGender': 'Female',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'Dental',
      'date': '2026-09-01',
      'startTime': '09:40',
      'endTime': '10:00',
      'appointmentType': 'in-center',
      'available': true,
    },
    {
      'slotId': 'SLOT-007',
      'doctorId': 'DOC-007',
      'doctorName': 'Dr. Ali Mansoor',
      'doctorGender': 'Male',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'Dental',
      'date': '2026-09-02',
      'startTime': '10:00',
      'endTime': '10:20',
      'appointmentType': 'tele',
      'available': true,
    },
    {
      'slotId': 'SLOT-008',
      'doctorId': 'DOC-006',
      'doctorName': 'Dr. Sara Mahmood',
      'doctorGender': 'Female',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'Dental',
      'date': '2026-09-03',
      'startTime': '11:20',
      'endTime': '11:40',
      'appointmentType': 'in-center',
      'available': true,
    },
    {
      'slotId': 'SLOT-009',
      'doctorId': 'DOC-007',
      'doctorName': 'Dr. Ali Mansoor',
      'doctorGender': 'Male',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'Dental',
      'date': '2026-09-03',
      'startTime': '13:00',
      'endTime': '13:20',
      'appointmentType': 'tele',
      'available': true,
    },
  ];

  final List<Map<String, dynamic>> _appointments = [
    {
      'appointmentId': 'APT-260901-001',
      'patientId': 'PAT-001',
      'slotId': 'SLOT-001',
      'bookingReference': 'NRK-APT-260829-0041',
      'status': 'confirmed',
      'doctorId': 'DOC-001',
      'doctorName': 'Dr. Noor Al Khalifa',
      'doctorGender': 'Female',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'General Clinic',
      'date': '2026-09-01',
      'startTime': '09:00',
      'endTime': '09:20',
      'appointmentType': 'in-center',
    },
    {
      'appointmentId': 'APT-260902-002',
      'patientId': 'PAT-001',
      'slotId': 'SLOT-003',
      'bookingReference': 'NRK-APT-260829-0048',
      'status': 'confirmed',
      'doctorId': 'DOC-003',
      'doctorName': 'Dr. Ahmed Salman',
      'doctorGender': 'Male',
      'healthCenterId': 'HC-001',
      'healthCenter': 'Naim Health Center',
      'clinic': 'General Clinic',
      'date': '2026-09-02',
      'startTime': '11:00',
      'endTime': '11:20',
      'appointmentType': 'tele',
      'teleLinkAvailable': true,
    },
  ];

  final List<Map<String, dynamic>> _vaccinations = [
    {
      'recordId': 'VAC-001',
      'patientId': 'PAT-001',
      'vaccineName': 'Influenza Vaccine',
      'vaccinationDate': '2025-03-10',
      'healthCenter': 'Naim Health Center',
      'certificateReference':
          'assets/documents/vaccination_certificate_2025.pdf',
      'missing': false,
      'dose': 'Annual dose',
      'category': 'Adult',
    },
    {
      'recordId': 'VAC-002',
      'patientId': 'PAT-001',
      'vaccineName': 'COVID-19 Booster',
      'vaccinationDate': '2024-11-21',
      'healthCenter': 'Naim Health Center',
      'certificateReference':
          'assets/documents/vaccination_certificate_2024.pdf',
      'missing': false,
      'dose': 'Booster dose',
      'category': 'Adult',
    },
    {
      'recordId': 'VAC-003',
      'patientId': 'PAT-001',
      'vaccineName': 'MMR (Measles, Mumps, Rubella)',
      'vaccinationDate': '2015-05-02',
      'healthCenter': 'Hoora Health Center',
      'certificateReference':
          'assets/documents/vaccination_certificate_2025.pdf',
      'missing': false,
      'dose': 'Dose 2 of 2',
      'category': 'Childhood',
    },
    {
      'recordId': 'VAC-004',
      'patientId': 'PAT-001',
      'vaccineName': 'DTaP (Diphtheria, Tetanus, Pertussis)',
      'vaccinationDate': '2013-09-18',
      'healthCenter': 'Hoora Health Center',
      'certificateReference':
          'assets/documents/vaccination_certificate_2025.pdf',
      'missing': false,
      'dose': 'Dose 5 of 5',
      'category': 'Childhood',
    },
    {
      'recordId': 'VAC-005',
      'patientId': 'PAT-001',
      'vaccineName': 'Yellow Fever',
      'vaccinationDate': '2023-07-04',
      'healthCenter': 'Naim Health Center',
      'certificateReference':
          'assets/documents/vaccination_certificate_2024.pdf',
      'missing': false,
      'dose': 'Single dose',
      'category': 'Travel',
    },
    {
      'recordId': 'VAC-006',
      'patientId': 'PAT-001',
      'vaccineName': 'Hepatitis B — 3rd dose',
      'vaccinationDate': '2024-01-20',
      'healthCenter': 'Naim Health Center',
      'certificateReference': null,
      'missing': true,
      'dose': 'Dose 3 of 3',
      'category': 'Adult',
    },
  ];

  // Bahrain-style clinical examples for UI demonstration only.
  // Vaccine names are real medical terms; records and dates are fictional.

  final List<Map<String, dynamic>> _reports = [
    {
      'reportId': 'REP-001',
      'patientId': 'PAT-001',
      'category': 'Laboratory',
      'reportType': 'Complete Blood Count (CBC)',
      'consultantId': 'DOC-010',
      'consultantName': 'Dr. Huda Yousif',
      'date': '2026-07-12',
      'status': 'ready',
      'documentReference': 'assets/documents/laboratory_report_2026.pdf',
    },
    {
      'reportId': 'REP-002',
      'patientId': 'PAT-001',
      'category': 'Radiology',
      'reportType': 'Chest X-ray',
      'consultantId': 'DOC-011',
      'consultantName': 'Dr. Amal Ibrahim',
      'date': '2026-06-03',
      'status': 'ready',
      'documentReference': 'assets/documents/radiology_report_2026.pdf',
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _visitedConsultants = {
    'Laboratory': [
      {
        'consultantId': 'DOC-010',
        'consultantName': 'Dr. Huda Yousif',
        'gender': 'Female'
      },
    ],
    'Radiology': [
      {
        'consultantId': 'DOC-011',
        'consultantName': 'Dr. Amal Ibrahim',
        'gender': 'Female'
      },
    ],
    'General Clinic': [
      {
        'consultantId': 'DOC-001',
        'consultantName': 'Dr. Noor Al Khalifa',
        'gender': 'Female'
      },
      {
        'consultantId': 'DOC-002',
        'consultantName': 'Dr. Layla Hassan',
        'gender': 'Female'
      },
    ],
    'Dental': [
      {
        'consultantId': 'DOC-020',
        'consultantName': 'Dr. Yousif Al Ansari',
        'gender': 'Male'
      },
    ],
    'Cardiology': [
      {
        'consultantId': 'DOC-021',
        'consultantName': 'Dr. Maryam Al Sayed',
        'gender': 'Female'
      },
    ],
    'Orthopedics': [
      {
        'consultantId': 'DOC-022',
        'consultantName': 'Dr. Khalid Bu Ali',
        'gender': 'Male'
      },
    ],
    'Dermatology': [
      {
        'consultantId': 'DOC-023',
        'consultantName': 'Dr. Reem Al Doseri',
        'gender': 'Female'
      },
    ],
    'ENT': [
      {
        'consultantId': 'DOC-024',
        'consultantName': 'Dr. Ahmed Salman',
        'gender': 'Male'
      },
    ],
  };

  final List<Map<String, dynamic>> _familyDoctors = [
    {
      'doctorId': 'DOC-001',
      'doctorName': 'Dr. Noor Al Khalifa',
      'gender': 'Female',
      'specialty': 'Family Medicine',
      'healthCenterId': 'HC-001',
      'capacityAvailable': true,
      'availableQuota': 5,
    },
    {
      'doctorId': 'DOC-004',
      'doctorName': 'Dr. Fatema Hasan',
      'gender': 'Female',
      'specialty': 'Family Medicine',
      'healthCenterId': 'HC-001',
      'capacityAvailable': true,
      'availableQuota': 2,
    },
    {
      'doctorId': 'DOC-005',
      'doctorName': 'Dr. Yaqoob Ali',
      'gender': 'Male',
      'specialty': 'Family Medicine',
      'healthCenterId': 'HC-001',
      'capacityAvailable': false,
      'availableQuota': 0,
    },
  ];

  final List<Map<String, dynamic>> _requests = [
    {
      'requestId': 'REQ-MR-260825-0142',
      'patientId': 'PAT-001',
      'serviceType': 'medical-report',
      'referenceNumber': 'NRK-MR-260825-0142',
      'status': 'processing',
      'createdAt': '2026-08-25T09:00:00Z',
      'updatedAt': '2026-08-27T12:00:00Z',
      'summary': 'General Clinic medical report request',
    },
    {
      'requestId': 'REQ-ADR-260820-0087',
      'patientId': 'PAT-001',
      'serviceType': 'address-update',
      'referenceNumber': 'NRK-ADR-260820-0087',
      'status': 'completed',
      'createdAt': '2026-08-20T07:30:00Z',
      'updatedAt': '2026-08-21T10:15:00Z',
      'summary': 'Residential block update completed',
    },
  ];

  final List<Map<String, dynamic>> _notifications = [
    {
      'notificationId': 'NOT-260829-001',
      'patientId': 'PAT-001',
      'type': 'appointment-reminder',
      'title': 'Appointment reminder',
      'body':
          'Your appointment at Naim Health Center is on 1 September 2026 at 09:00.',
      'read': false,
      'createdAt': '2026-08-29T08:00:00Z',
      'routeTarget': '/appointments',
    },
    {
      'notificationId': 'NOT-260827-002',
      'patientId': 'PAT-001',
      'type': 'request-status',
      'title': 'Medical report request updated',
      'body': 'Your medical report request is being processed.',
      'read': true,
      'createdAt': '2026-08-27T12:05:00Z',
      'routeTarget': '/pending-requests',
    },
  ];

  int _sequence = 100;
  String _nextId(String prefix) => '$prefix-${_sequence++}';

  // -----------------------------
  // Authentication (simulated eKey)
  // -----------------------------
  Future<Map<String, dynamic>> simulateEkeyLogin() async {
    await _wait();

    final cprExpiryDate = DateTime.parse(_patient['cprExpiryDate'] as String);
    final now = DateTime.now();
    final expiresIn = cprExpiryDate.difference(now).inSeconds;

    if (expiresIn <= 0) {
      throw const NaraakApiException(
        statusCode: 401,
        code: 'CPR_EXPIRED',
        message:
            'Your CPR has expired. Please renew your CPR before signing in.',
      );
    }

    return _success({
      'accessToken': 'eyJ.demo.naraak.access',
      'refreshToken': 'eyJ.demo.naraak.refresh',
      'expiresIn': expiresIn,
      'expiresAt': _patient['cprExpiryDate'],
      'user': _patient,
      'simulated': true,
      'dataClassification': 'fictional-realistic-demo',
    });
  }

  // -----------------------------
  // Profile / Home / Family
  // -----------------------------
  Future<Map<String, dynamic>> getProfile() async {
    await _wait();
    return _success(Map<String, dynamic>.from(_patient));
  }

  Future<Map<String, dynamic>> getHomeDashboard() async {
    await _wait();
    final upcoming =
        _appointments.where((a) => a['status'] != 'cancelled').toList();
    return _success({
      'patient': _patient,
      'nextAppointment': upcoming.isEmpty ? null : upcoming.first,
      'pendingRequests':
          _requests.where((r) => r['status'] != 'completed').toList(),
      'unreadNotifications':
          _notifications.where((n) => n['read'] == false).length,
    });
  }

  Future<Map<String, dynamic>> getFamilyMembers() async {
    await _wait();
    return _success(List<Map<String, dynamic>>.from(_familyMembers));
  }

  // -----------------------------
  // Booking Appointments
  // -----------------------------
  // Booking flow:
  // 1) Choose appointment type: in-center or tele
  // 2) Choose clinic: General Clinic or Dental
  // 3) Filter by doctor/gender/date/time if needed
  // 4) Choose an available slot and confirm booking
  Future<Map<String, dynamic>> getAppointmentClinics(
      {required String appointmentType}) async {
    await _wait();
    const allowedTypes = {'in-center', 'tele'};
    if (!allowedTypes.contains(appointmentType)) {
      throw const NaraakApiException(
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Appointment type must be in-center or tele.',
      );
    }
    return _success({
      'appointmentType': appointmentType,
      'clinics': ['General Clinic', 'Dental'],
    });
  }

  Future<Map<String, dynamic>> getAppointmentSlots({
    required String appointmentType,
    required String clinic,
    String? healthCenterId,
    String? doctorId,
    String? doctorGender,
    String? date,
    bool earliestAvailable = false,
  }) async {
    await _wait();
    const allowedAppointmentTypes = {'in-center', 'tele'};
    const allowedClinics = {'General Clinic', 'Dental'};
    const allowedDoctorGenders = {'Female', 'Male'};

    if (!allowedAppointmentTypes.contains(appointmentType)) {
      throw const NaraakApiException(
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Appointment type must be in-center or tele.',
      );
    }
    if (!allowedClinics.contains(clinic)) {
      throw const NaraakApiException(
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Clinic must be General Clinic or Dental.',
      );
    }
    if (doctorGender != null && !allowedDoctorGenders.contains(doctorGender)) {
      throw const NaraakApiException(
        statusCode: 400,
        code: 'VALIDATION_ERROR',
        message: 'Doctor gender must be Female or Male.',
      );
    }

    var result = _slots.where((s) {
      if (s['available'] != true) return false;
      if (s['appointmentType'] != appointmentType) return false;
      if (s['clinic'] != clinic) return false;
      if (healthCenterId != null && s['healthCenterId'] != healthCenterId)
        return false;
      if (doctorId != null && s['doctorId'] != doctorId) return false;
      if (doctorGender != null && s['doctorGender'] != doctorGender)
        return false;
      if (date != null && s['date'] != date) return false;
      return true;
    }).toList();

    if (earliestAvailable && result.isNotEmpty) result = [result.first];
    return _success({'appointments': result});
  }

  Future<Map<String, dynamic>> bookAppointment({
    required String patientId,
    required String slotId,
    required String appointmentType,
  }) async {
    await _wait();
    final index = _slots.indexWhere((s) => s['slotId'] == slotId);
    if (index < 0) {
      throw const NaraakApiException(
          statusCode: 404,
          code: 'NOT_FOUND',
          message: 'Appointment slot was not found.');
    }
    if (_slots[index]['available'] != true) {
      throw const NaraakApiException(
          statusCode: 409,
          code: 'RESOURCE_CONFLICT',
          message: 'This slot is no longer available.');
    }
    _slots[index]['available'] = false;
    final a = {
      'appointmentId': _nextId('APT'),
      'patientId': patientId,
      'bookingReference': _nextId('NRK-APT'),
      'status': 'confirmed',
      ..._slots[index],
    };
    _appointments.add(a);
    _notifications.add({
      'notificationId': _nextId('NOT'),
      'patientId': patientId,
      'type': 'appointment-confirmation',
      'title': 'Appointment confirmed',
      'body':
          'Your appointment has been confirmed. You can view the details in My Appointments.',
      'read': false,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'routeTarget': '/appointments',
    });
    return _success(a);
  }

  Future<Map<String, dynamic>> getMyAppointments(
      {required String patientId}) async {
    await _wait();
    return _success(
        _appointments.where((a) => a['patientId'] == patientId).toList());
  }

  Future<Map<String, dynamic>> getTeleAppointmentDetails(
      {required String appointmentId}) async {
    await _wait();
    return _success({
      'appointmentId': appointmentId,
      'teleStatus': 'ready',
      'joinLink': 'https://video.naraak.example/consultation/APT-TELE-001',
      'instructions': [
        'Check your internet connection.',
        'Use a quiet private place.',
        'Tap Join when your appointment time starts.',
      ],
      'privacyMessage':
          'Use a private place and do not share the consultation link.',
    });
  }

  Future<Map<String, dynamic>> resendTeleLink(
      {required String appointmentId}) async {
    await _wait();
    return _success({'appointmentId': appointmentId, 'resendStatus': 'sent'});
  }

  // -----------------------------
  // Vaccinations
  // -----------------------------
  Future<Map<String, dynamic>> getVaccinations(
      {required String patientId}) async {
    await _wait();
    return _success(
        _vaccinations.where((v) => v['patientId'] == patientId).toList());
  }

  Future<Map<String, dynamic>> reportMissingVaccination({
    required String patientId,
    required String uploadedDocument,
    required String contactNumber,
    String? comments,
  }) async {
    await _wait();
    if (uploadedDocument.trim().isEmpty) {
      throw const NaraakApiException(
          statusCode: 400,
          code: 'VALIDATION_ERROR',
          message: 'Supporting document is required.');
    }
    return _createRequest(patientId, 'missing-vaccination', {
      'uploadedDocument': uploadedDocument,
      'contactNumber': contactNumber,
      'comments': comments,
    });
  }

  // -----------------------------
  // Medical Reports
  // -----------------------------
  Future<Map<String, dynamic>> getMedicalReports(
      {required String patientId, String? type}) async {
    await _wait();
    var list = _reports.where((r) => r['patientId'] == patientId).toList();
    if (type != null) list = list.where((r) => r['category'] == type).toList();
    return _success(list);
  }

  Future<Map<String, dynamic>> getVisitedConsultants(
      {required String category}) async {
    await _wait();
    return _success(_visitedConsultants[category] ?? <Map<String, dynamic>>[]);
  }

  Future<Map<String, dynamic>> requestMedicalReport({
    required String patientId,
    required String category,
    required String consultantId,
    required String reason,
    required String contactNumber,
  }) async {
    await _wait();
    return _createRequest(patientId, 'medical-report', {
      'category': category,
      'consultantId': consultantId,
      'reason': reason,
      'contactNumber': contactNumber,
    });
  }

  // -----------------------------
  // Newborn Sehati Card
  // -----------------------------
  Future<Map<String, dynamic>> getDummyNewbornRegistryData(
      {required String guardianPatientId}) async {
    await _wait();
    return _success({
      'newbornCpr': '260815214',
      'fatherCpr': '880410563',
      'motherCpr': '900922418',
      'contactNumber': _patient['phone'],
      'residentialBlock': '321',
      'registryMatch': true,
      'simulated': true,
    });
  }

  Future<Map<String, dynamic>> submitNewbornCard({
    required String patientId,
    required String newbornCpr,
    required String fatherCpr,
    required String motherCpr,
    required String contactNumber,
    required String residentialBlock,
    String? notes,
  }) async {
    await _wait();
    return _createRequest(patientId, 'newborn-card', {
      'newbornCpr': newbornCpr,
      'fatherCpr': fatherCpr,
      'motherCpr': motherCpr,
      'contactNumber': contactNumber,
      'residentialBlock': residentialBlock,
      'notes': notes,
    });
  }

  // -----------------------------
  // Hajj Certificate
  // -----------------------------
  Future<Map<String, dynamic>> getHajjCertificateStatus(
      {required String patientId}) async {
    await _wait();
    return _success({
      'patientId': patientId,
      'doctorVisitRequired': true,
      'doctorVisitVerified': true,
      'status': 'ready',
      'certificateReference': 'assets/documents/hajj_certificate_2026.pdf',
      'qrReference': 'assets/qr/hajj_certificate_2026.png',
    });
  }

  Future<Map<String, dynamic>> requestHajjCertificate(
      {required String patientId}) async {
    await _wait();
    return _createRequest(
        patientId, 'hajj-certificate', {'doctorVisitVerified': true});
  }

  // -----------------------------
  // Address Update
  // -----------------------------
  Future<Map<String, dynamic>> updateAddress({
    required String patientId,
    required String previousBlock,
    required String newBlock,
    required bool consent,
    String? contactNumber,
  }) async {
    await _wait();
    if (!consent) {
      throw const NaraakApiException(
          statusCode: 400,
          code: 'VALIDATION_ERROR',
          message: 'Consent is required.');
    }
    _patient['healthCenter'] = {
      'id': 'HC-002',
      'name': 'Salmabad Health Center',
    };
    return _success({
      'requestId': _nextId('REQ'),
      'referenceNumber': _nextId('NRK-ADR'),
      'status': 'completed',
      'previousBlock': previousBlock,
      'newBlock': newBlock,
      'newlyAssignedHealthCenter': _patient['healthCenter'],
    });
  }

  // -----------------------------
  // Fee Exemption
  // -----------------------------
  Future<Map<String, dynamic>> getFeeExemptionDocumentChecklist() async {
    await _wait();
    return _success([
      {'name': 'CPR / Identity copy', 'required': true},
      {'name': 'Recent supporting medical report', 'required': false},
      {
        'name': 'Residency / supporting document if applicable',
        'required': false
      },
    ]);
  }

  Future<Map<String, dynamic>> submitFeeExemption({
    required String patientId,
    required String requestType,
    required Map<String, dynamic> personalDetails,
    required List<String> supportingDocuments,
    required bool consent,
  }) async {
    await _wait();
    if (!consent)
      throw const NaraakApiException(
          statusCode: 400,
          code: 'VALIDATION_ERROR',
          message: 'Consent is required.');
    return _createRequest(patientId, 'fee-exemption', {
      'requestType': requestType,
      'personalDetails': personalDetails,
      'supportingDocuments': supportingDocuments,
    });
  }

  // -----------------------------
  // Mobile Unit
  // -----------------------------
  Future<Map<String, dynamic>> requestMobileUnit({
    required String patientId,
    required String contactNumber,
    required String blockNumber,
    required String address,
    required String reason,
    String? verifiedFamilyMemberId,
  }) async {
    await _wait();
    return _createRequest(patientId, 'mobile-unit', {
      'contactNumber': contactNumber,
      'blockNumber': blockNumber,
      'address': address,
      'reason': reason,
      'verifiedFamilyMemberId': verifiedFamilyMemberId,
      'scheduledDateTime': '2026-09-05T07:00:00Z',
    });
  }

  // -----------------------------
  // Mammogram
  // -----------------------------
  Future<Map<String, dynamic>> checkMammogramEligibility(
      {required String patientId}) async {
    await _wait();
    return _success({
      'eligible': true,
      'ageEligible': true,
      'lastScreeningDate': '2023-06-01',
      'checkedFromRegistry': true,
      'simulated': true,
    });
  }

  Future<Map<String, dynamic>> requestMammogram({
    required String patientId,
    required String contactNumber,
  }) async {
    await _wait();
    return _createRequest(patientId, 'mammogram', {
      'contactNumber': contactNumber,
      'eligibilityStatus': 'eligible',
    });
  }

  // -----------------------------
  // Family Doctor
  // -----------------------------
  Future<Map<String, dynamic>> getAvailableFamilyDoctors(
      {required String healthCenterId}) async {
    await _wait();
    return _success(_familyDoctors
        .where((d) => d['healthCenterId'] == healthCenterId)
        .toList());
  }

  Future<Map<String, dynamic>> requestFamilyDoctorChange({
    required String patientId,
    required String requestedDoctorId,
    required String reason,
    required bool consent,
  }) async {
    await _wait();
    final doctor = _familyDoctors
        .where((d) => d['doctorId'] == requestedDoctorId)
        .firstOrNull;
    if (doctor == null)
      throw const NaraakApiException(
          statusCode: 404, code: 'NOT_FOUND', message: 'Doctor not found.');
    if (doctor['capacityAvailable'] != true) {
      throw const NaraakApiException(
          statusCode: 409,
          code: 'NO_CAPACITY',
          message: 'The selected doctor has no available quota.');
    }
    if (!consent)
      throw const NaraakApiException(
          statusCode: 400,
          code: 'VALIDATION_ERROR',
          message: 'Consent is required.');
    return _createRequest(patientId, 'family-doctor-change', {
      'requestedDoctorId': requestedDoctorId,
      'reason': reason,
      'capacityVerified': true,
    });
  }

  // -----------------------------
  // Research Application
  // -----------------------------
  Future<Map<String, dynamic>> submitResearchApplication({
    required String patientId,
    required String applicantType,
    required Map<String, dynamic> applicantDetails,
    required Map<String, dynamic> supervisorDetails,
    required Map<String, dynamic> researchDetails,
    required List<String> supportingDocuments,
  }) async {
    await _wait();
    const allowedTypes = {'Student', 'Employee', 'Delegate'};
    if (!allowedTypes.contains(applicantType)) {
      throw const NaraakApiException(
          statusCode: 400,
          code: 'VALIDATION_ERROR',
          message: 'Invalid applicant type.');
    }
    return _createRequest(patientId, 'research-application', {
      'applicantType': applicantType,
      'applicantDetails': applicantDetails,
      'supervisorDetails': supervisorDetails,
      'researchDetails': researchDetails,
      'supportingDocuments': supportingDocuments,
    });
  }

  // -----------------------------
  // Pending Requests / Notifications
  // -----------------------------
  Future<Map<String, dynamic>> getPendingRequests(
      {required String patientId, String? status}) async {
    await _wait();
    var list = _requests.where((r) => r['patientId'] == patientId).toList();
    if (status != null)
      list = list.where((r) => r['status'] == status).toList();
    return _success(list);
  }

  Future<Map<String, dynamic>> getRequestById(
      {required String requestId}) async {
    await _wait();
    final list = _requests.where((r) => r['requestId'] == requestId).toList();
    if (list.isEmpty)
      throw const NaraakApiException(
          statusCode: 404, code: 'NOT_FOUND', message: 'Request not found.');
    return _success(list.first);
  }

  Future<Map<String, dynamic>> getNotifications(
      {required String patientId, bool unreadOnly = false}) async {
    await _wait();
    var list =
        _notifications.where((n) => n['patientId'] == patientId).toList();
    if (unreadOnly) list = list.where((n) => n['read'] == false).toList();
    return _success(list);
  }

  Future<Map<String, dynamic>> markNotificationRead(
      {required String notificationId}) async {
    await _wait();
    final index =
        _notifications.indexWhere((n) => n['notificationId'] == notificationId);
    if (index < 0)
      throw const NaraakApiException(
          statusCode: 404,
          code: 'NOT_FOUND',
          message: 'Notification not found.');
    _notifications[index]['read'] = true;
    return _success(_notifications[index]);
  }

  Future<Map<String, dynamic>> submitSupportMessage({
    required String patientId,
    required String category,
    required String subject,
    required String message,
  }) async {
    await _wait();
    return _createRequest(patientId, category, {
      'subject': subject,
      'message': message,
    });
  }

  Map<String, dynamic> _createRequest(
      String patientId, String serviceType, Map<String, dynamic> payload) {
    final request = {
      'requestId': _nextId('REQ'),
      'patientId': patientId,
      'serviceType': serviceType,
      'referenceNumber': _nextId('NRK'),
      'status': 'submitted',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
      'payload': payload,
    };
    _requests.add(request);
    return _success(request);
  }
}

/// Compatibility helper because Iterable.firstOrNull is not available on all

extension FirstOrNullExtension<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
