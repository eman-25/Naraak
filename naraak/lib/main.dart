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
import 'providers/notifications_read_provider.dart';
import 'screens/home_screen.dart';
import 'screens/services_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/pending_requests_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/family_members_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/app_settings_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/splash_screen.dart';

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
        ChangeNotifierProvider(create: (_) => NotificationsReadProvider()),
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
          home: const SplashScreen(),
          // Only pre-shell routes live here. Everything reachable once
          // inside the app (services, pending requests, notifications,
          // profile sub-pages) is registered on RootShell's own nested
          // Navigator below, so the bottom nav — and a working back
          // button — stay visible on every one of those screens, per the
          // Phase 3 wireframes (every mockup screen keeps the 4-tab bar).
          routes: {
            '/login': (_) => const LoginScreen(),
            '/profile-setup': (_) => const ProfileSetupScreen(),
            '/home': (_) => const RootShell(),
          },
          onGenerateRoute: (settings) => settings.name == '/'
              ? MaterialPageRoute(builder: (_) => const RootShell())
              : null,
        ),
      ),
    );
  }
}

/// Lets any screen nested inside [RootShell] switch bottom-nav tabs
/// (e.g. the Home tab's "All Services" tile jumping to the Services tab)
/// without needing a route name for something that isn't a route.
class ShellNavigation extends InheritedWidget {
  final ValueChanged<int> selectTab;

  const ShellNavigation(
      {super.key, required this.selectTab, required super.child});

  static ShellNavigation? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellNavigation>();

  @override
  bool updateShouldNotify(ShellNavigation oldWidget) => false;
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _tabIndex = ValueNotifier<int>(0);

  static const _screens = [
    HomeScreen(),
    AppointmentsScreen(),
    ServicesScreen(),
    ProfileScreen(),
  ];

  static final Map<String, WidgetBuilder> _shellRoutes = {
    '/pending-requests': (_) => const PendingRequestsScreen(),
    '/profile/family': (_) => const FamilyMembersScreen(),
    '/profile/personal-info': (_) => const PersonalInfoScreen(),
    '/profile/app-settings': (_) => const AppSettingsScreen(),
    '/profile/privacy-security': (_) => const PrivacySecurityScreen(),
    '/profile/help-support': (_) => const HelpSupportScreen(),
    '/notifications': (_) => const NotificationsScreen(),
    ...AppRouter.routes,
  };

  void _selectTab(int index) {
    // Tapping a tab returns to that tab's root, matching how the bottom
    // nav behaves in the wireframes (it's always the 4-tab entry points).
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    _tabIndex.value = index;
    setState(() {});
  }

  @override
  void dispose() {
    _tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShellNavigation(
        selectTab: _selectTab,
        child: Navigator(
          key: _navigatorKey,
          onGenerateRoute: (settings) {
            if (settings.name == '/' || settings.name == null) {
              return MaterialPageRoute(
                builder: (_) => ValueListenableBuilder<int>(
                  valueListenable: _tabIndex,
                  builder: (_, index, __) =>
                      IndexedStack(index: index, children: _screens),
                ),
              );
            }
            final builder = _shellRoutes[settings.name];
            if (builder != null) {
              return MaterialPageRoute(builder: builder, settings: settings);
            }
            return null;
          },
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _tabIndex,
        builder: (_, index, __) => BottomNavigationBar(
          currentIndex: index,
          onTap: _selectTab,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.event_note_outlined),
                activeIcon: Icon(Icons.event_note),
                label: 'Appointments'),
            BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view),
                label: 'Services'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
