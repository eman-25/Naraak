// lib/main.dart — only the changed parts shown
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'localization/app_localizations.dart';
import 'routes/app_router.dart';
import 'providers/app_settings_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/vaccination_provider.dart';
import 'providers/service_request_provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/change_doctor_provider.dart';
import 'providers/fee_exemption_provider.dart';
import 'providers/hajj_certificate_provider.dart';
import 'providers/family_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/services_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/pending_requests_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/appearance_settings_screen.dart';
import 'screens/family_members_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/notifications_screen.dart';

void main() => runApp(const NaraakApp());

class NaraakApp extends StatelessWidget {
  const NaraakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => VaccinationProvider()),
        ChangeNotifierProvider(create: (_) => ServiceRequestProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => ChangeDoctorProvider()),
        ChangeNotifierProvider(create: (_) => FeeExemptionProvider()),
        ChangeNotifierProvider(create: (_) => HajjCertificateProvider()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) => MaterialApp(
          title: 'Naraak',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(settings.palette),
          darkTheme: AppTheme.dark(settings.palette),
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [AppLocalizationsDelegate()],
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(settings.textScale)),
            child: child!,
          ),
          home: const LoginScreen(),
          routes: {
            '/login': (_) => const LoginScreen(),
            '/profile-setup': (_) => const ProfileSetupScreen(),
            '/home': (_) => const RootShell(),
            '/pending-requests': (_) => const PendingRequestsScreen(),
            '/profile/appearance': (_) => const AppearanceSettingsScreen(),
            '/profile/family': (_) => const FamilyMembersScreen(),
            '/profile/personal-info': (_) => const PersonalInfoScreen(),
            '/notifications': (_) => const NotificationsScreen(),
            ...AppRouter.routes,
          },
          onGenerateRoute: (settings) => settings.name == '/'
              ? MaterialPageRoute(builder: (_) => const RootShell())
              : null,
        ),
      ),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  static const _screens = [
    HomeScreen(),
    ServicesScreen(),
    AppointmentsScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Services'),
          BottomNavigationBarItem(
              icon: Icon(Icons.event_note_outlined),
              activeIcon: Icon(Icons.event_note),
              label: 'Appointments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
      ),
    );
  }
}
