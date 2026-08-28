import 'package:flutter/material.dart';
import '../screens/services/booking_entry_screen.dart';
import '../screens/services/vaccination_records_screen.dart';
import '../screens/services/address_update_screen.dart';
import '../screens/services/change_family_doctor_screen.dart';
import '../screens/services/fee_exemption_screen.dart';
import '../screens/services/hajj_certificate_screen.dart';
import '../screens/services/mammogram_screening_screen.dart';
import '../screens/services/medical_reports_screen.dart';
import '../screens/services/mobile_unit_screen.dart';
import '../screens/services/newborn_sehati_card_screen.dart';
import '../screens/services/phc_research_screen.dart';
import '../screens/services/tele_appointment_screen.dart';
import '../screens/appointments_screen.dart';

/// Named routes — 1:1 with the Phase 3 sitemap (Phase 6 §7).
class AppRouter {
  AppRouter._();

  static const home = '/home';
  static const services = '/services';
  static const profile = '/profile';
  static const appointments = '/appointments';

  static Map<String, WidgetBuilder> get routes => {
        appointments: (_) => const AppointmentsScreen(),
        '/services/booking': (_) => const BookingEntryScreen(),
        '/services/vaccinations': (_) => const VaccinationRecordsScreen(),
        '/services/address-update': (_) => const AddressUpdateScreen(),
        '/services/change-doctor': (_) => const ChangeFamilyDoctorScreen(),
        '/services/fee-exemption': (_) => const FeeExemptionScreen(),
        '/services/hajj-certificate': (_) => const HajjCertificateScreen(),
        '/services/mammogram': (_) => const MammogramScreeningScreen(),
        '/services/medical-reports': (_) => const MedicalReportsScreen(),
        '/services/mobile-unit': (_) => const MobileUnitScreen(),
        '/services/newborn-sehati': (_) => const NewbornSehatiCardScreen(),
        '/services/phc-research': (_) => const PhcResearchScreen(),
        '/services/tele-appointment': (_) => const TeleAppointmentScreen(),
      };
}
