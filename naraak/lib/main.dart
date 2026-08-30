// lib/main.dart — only the changed parts shown
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'responsive/breakpoints.dart';
import 'web/web_sidebar.dart';
import 'web/web_mini_topbar.dart';
import 'web/web_home_screen.dart';
import 'widgets/mobile_top_bar.dart';

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
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
            '/services-tab': (_) => const RootShell(initialIndex: 2),
            '/profile': (_) => const RootShell(initialIndex: 3),
            '/appointments': (_) => const RootShell(initialIndex: 1),
            '/pending-requests': (_) => const PendingRequestsScreen(),
            '/profile/appearance': (_) => const AppearanceSettingsScreen(),
            '/profile/family': (_) => const FamilyMembersScreen(),
            '/profile/personal-info': (_) => const PersonalInfoScreen(),
            '/notifications': (_) => const NotificationsScreen(),
            ...AppRouter.routes,
            '/appointments': (_) => const RootShell(initialIndex: 1),
          },
          onGenerateRoute: (settings) => settings.name == '/'
              ? MaterialPageRoute(builder: (_) => const RootShell())
              : null,
        ),
      ),
    );
  }
}

/// Lets any screen nested inside [RootShell] switch bottom-nav tabs (e.g.
/// the Home tab's "All Services" tile jumping to the Services tab) and lets
/// the shell's own persistent chrome — [MobileTopBar], [WebMiniTopBar],
/// [WebSidebar] — push routes onto the shell's nested Navigator.
///
/// That chrome sits as a *sibling* of the nested Navigator (both live
/// directly under RootShell's Scaffold), not a descendant of it. A plain
/// `Navigator.push(context, ...)` called from inside it resolves to the
/// outer app-level Navigator instead — which has no route for e.g.
/// '/notifications' — and silently does nothing: no error, no navigation.
/// Routing shell-chrome taps through [navigatorKey] instead targets the
/// correct (nested) Navigator explicitly.
class ShellNavigation extends InheritedWidget {
  final ValueChanged<int> selectTab;
  final GlobalKey<NavigatorState> navigatorKey;

  const ShellNavigation({
    super.key,
    required this.selectTab,
    required this.navigatorKey,
    required super.child,
  });

  static ShellNavigation? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ShellNavigation>();

  Future<T?> pushNamed<T extends Object?>(String routeName) =>
      navigatorKey.currentState!.pushNamed<T>(routeName);

  Future<T?> push<T extends Object?>(Route<T> route) =>
      navigatorKey.currentState!.push<T>(route);

  @override
  bool updateShouldNotify(ShellNavigation oldWidget) =>
      selectTab != oldWidget.selectTab || navigatorKey != oldWidget.navigatorKey;
}

class RootShell extends StatefulWidget {
  final int initialIndex;
  const RootShell({super.key, this.initialIndex = 0});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late int _index;
  static const _screens = [
    HomeScreen(),
    AppointmentsScreen(),
    ServicesScreen(),
    ProfileScreen()
  ];

  // Home gets a bespoke wide dashboard on web; the rest reuse the mobile
  // screens for now (centered by RootShell below) until each gets its own
  // desktop layout pass.
  static const _webScreens = [
    WebHomeScreen(),
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

  static const _pageLabels = ['Home', 'Appointments', 'Services', 'Profile'];

  Widget _buildNavigator(bool web, List<Widget> screens) {
    return Navigator(
      key: _navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == '/' || settings.name == null) {
          return MaterialPageRoute(
            builder: (_) => ValueListenableBuilder<int>(
              valueListenable: _tabIndex,
              builder: (_, index, __) {
                final stack = IndexedStack(index: index, children: screens);
                // All four root tabs now manage their own width/centering.
                if (!web || index <= 3) return stack;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: stack,
                  ),
                );
              },
            ),
          );
        }
        final builder = _shellRoutes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(builder: builder, settings: settings);
        }
        return null;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

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
