// lib/main.dart — only the changed parts shown
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'data/naraak_repository.dart';
import 'localization/app_localizations.dart';
import 'routes/app_router.dart';
import 'providers/app_settings_provider.dart';
import 'providers/clinical_data_provider.dart';
import 'providers/dashboard_provider.dart';
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
import 'screens/ekey_login_screen.dart';
import 'screens/profile_setup_screen.dart';
import 'screens/family_members_screen.dart';
import 'screens/personal_info_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/app_settings_screen.dart';
import 'screens/privacy_security_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/naraak_splash_screen.dart';
import 'screens/logo_animation_screen.dart';
import 'screens/welcome_screen.dart';
import 'responsive/breakpoints.dart';
import 'web/web_sidebar.dart';
import 'web/web_mini_topbar.dart';
import 'web/web_home_screen.dart';
import 'widgets/mobile_top_bar.dart';
import 'widgets/naraak_bottom_navigation.dart';

void main() => runApp(const NaraakApp());

class NaraakApp extends StatelessWidget {
  const NaraakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => NaraakRepository()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                ClinicalDataProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                DashboardProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                AppointmentProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                VaccinationProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                ServiceRequestProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                UserProfileProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                ChangeDoctorProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                FeeExemptionProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                HajjCertificateProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                FamilyProvider(context.read<NaraakRepository>())),
        ChangeNotifierProvider(
            create: (context) =>
                AuthProvider(context.read<NaraakRepository>())),
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
          home: const NaraakSplashScreen(),
          // Only pre-shell routes live here. Everything reachable once
          // inside the app (services, pending requests, notifications,
          // profile sub-pages) is registered on RootShell's own nested
          // Navigator below, so the bottom nav — and a working back
          // button — stay visible on every one of those screens, per the
          // Phase 3 wireframes (every mockup screen keeps the 4-tab bar).
          routes: {
            '/logo-animation': (_) => const LogoAnimationScreen(),
            '/welcome': (_) => const WelcomeScreen(),
            '/login': (_) => const EkeyLoginScreen(),
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
      selectTab != oldWidget.selectTab ||
      navigatorKey != oldWidget.navigatorKey;
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _tabIndex = ValueNotifier<int>(0);

  static const _mobileScreens = [
    HomeScreen(),
    AppointmentsScreen(),
    ServicesScreen(),
    ProfileScreen(),
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
  Widget build(BuildContext context) {
    final web = isWebWidth(context);
    final screens = web ? _webScreens : _mobileScreens;

    if (web) {
      return ShellNavigation(
        selectTab: _selectTab,
        navigatorKey: _navigatorKey,
        child: Scaffold(
          body: Row(
            children: [
              WebSidebar(
                  currentIndex: _tabIndex.value, onSelectTab: _selectTab),
              Expanded(
                child: Column(
                  children: [
                    WebMiniTopBar(pageLabel: _pageLabels[_tabIndex.value]),
                    Expanded(child: _buildNavigator(true, screens)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ShellNavigation(
      selectTab: _selectTab,
      navigatorKey: _navigatorKey,
      child: Scaffold(
        appBar: const MobileTopBar(),
        body: _buildNavigator(false, screens),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _tabIndex,
          builder: (_, index, __) => NaraakBottomNavigation(
            currentIndex: index,
            onDestinationSelected: _selectTab,
          ),
        ),
      ),
    );
  }
}
