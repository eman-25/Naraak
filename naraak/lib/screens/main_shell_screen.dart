// lib/screens/main_shell_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_top_bar.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'appointments_screen.dart';
import 'services_screen.dart';
import 'profile_screen.dart';

/// Root shell wrapper that maintains persistent navigation bar and top header across primary tabs.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  // Primary top-level navigation screens
  final List<Widget> _pages = const [
    HomeScreen(),
    AppointmentsScreen(),
    ServicesScreen(),
    ProfileScreen(),
  ];

  // Dynamic header titles per active tab
  final List<String> _titles = const [
    'Home',
    'Appointments',
    'Services',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    final palette = AppPaletteExtension.of(context);

    return Scaffold(
      // Persistent top header (hides back button for top-level tabs)
      appBar: AppTopBar(
        title: _titles[_currentIndex],
        showBackButton: false,
      ),

      // Retains state of all tabs using IndexedStack
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // Custom floating/curved bottom navigation footer matching design specs
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: palette.primary,
            unselectedItemColor: AppColors.ink500,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_month_rounded),
                label: 'Appointments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_outlined),
                activeIcon: Icon(Icons.grid_view_rounded),
                label: 'Services',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}