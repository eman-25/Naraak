import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../models/appointment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

enum AppointmentType { inPerson, teleConsultation }

enum BookingMethod { byDateAndDoctor, availableToday, closestSlot }

class BookingAppointmentScreen extends StatefulWidget {
  const BookingAppointmentScreen({super.key});

  @override
  State<BookingAppointmentScreen> createState() =>
      _BookingAppointmentScreenState();
}

class _BookingAppointmentScreenState extends State<BookingAppointmentScreen> {
  // Navigation Flow States:
  // 0: Selection Menu, 1: Slots List, 2: Review/Confirm, 3: Success Pass
  int _currentFlowStep = 0;

  AppointmentType _selectedType = AppointmentType.inPerson;
  BookingMethod _bookingMethod = BookingMethod.byDateAndDoctor;
  DateTime? _selectedDate;
  Appointment? _selectedSlot;
  bool _isBooking = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadAvailableSlots();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      appBar: AppTopBar(
        title: _getAppBarTitle(),
        showBackButton: _currentFlowStep > 0 && _currentFlowStep != 3,
        onBack: () => setState(() => _currentFlowStep--),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_currentFlowStep == 1) ...[
              // Search Input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Doctor or Center...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.primaryTeal),
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear,
                                color: AppColors.primaryTeal),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),

              // In-Person vs Tele-Consultation Toggle Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryIce,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildTypeSegment(AppointmentType.inPerson,
                              'In-Person', Icons.medical_services_outlined)),
                      Expanded(
                          child: _buildTypeSegment(
                              AppointmentType.teleConsultation,
                              'Tele Visit',
                              Icons.video_call_outlined)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Active Flow Screen Body
            Expanded(
              child: IndexedStack(
                index: _currentFlowStep,
                children: [
                  _buildBookingMenuSection(),
                  _buildAvailableSlotsSection(),
                  _buildReviewDetailsSection(profile),
                  _buildBookingSuccessPassSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentFlowStep) {
      case 1:
        return 'Available Slots';
      case 2:
      case 3:
        return 'Book Appointment';
      default:
        return 'Book Appointment';
    }
  }

  // --- Step 0: Initial Options Menu ---
  Widget _buildBookingMenuSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Book Appointment By:', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          _buildMenuOptionCard(
            icon: Icons.calendar_today_outlined,
            title: 'Depending on date and the doctor',
            onTap: () => _startBooking(BookingMethod.byDateAndDoctor),
          ),
          const SizedBox(height: 12),
          _buildMenuOptionCard(
            icon: Icons.access_time,
            title: 'Closest appointment',
            onTap: () => _startBooking(BookingMethod.closestSlot),
          ),
          const SizedBox(height: 12),
          _buildMenuOptionCard(
            icon: Icons.person_outline,
            title: 'Available Slots',
            onTap: () => _startBooking(BookingMethod.availableToday),
          ),
        ],
      ),
    );
  }

  Future<void> _startBooking(BookingMethod method) async {
    DateTime? date;
    if (method == BookingMethod.byDateAndDoctor) {
      date = await showDatePicker(
        context: context,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 90)),
        initialDate: DateTime.now(),
      );
      if (!mounted || date == null) return;
    }

    setState(() {
      _bookingMethod = method;
      _selectedDate = date;
      _searchController.clear();
      _currentFlowStep = 1;
    });
  }

  // --- Step 1: Available Slots / No Slots Exception View ---
  Widget _buildAvailableSlotsSection() {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, _) {
        final query = _searchController.text.trim().toLowerCase();
        final now = DateTime.now();
        final slots = provider.availableSlots.where((slot) {
          final matchesMethod = switch (_bookingMethod) {
            BookingMethod.byDateAndDoctor => _selectedDate == null ||
                _isSameDate(slot.slotDateTime, _selectedDate!),
            BookingMethod.availableToday => _isSameDate(slot.slotDateTime, now),
            BookingMethod.closestSlot => true,
          };
          return matchesMethod &&
              (query.isEmpty ||
                  slot.doctorName.toLowerCase().contains(query) ||
                  slot.centerName.toLowerCase().contains(query));
        }).toList();
        if (_bookingMethod == BookingMethod.closestSlot) {
          slots.sort((first, second) =>
              first.slotDateTime.compareTo(second.slotDateTime));
        }

        if (provider.slotsState == LoadState.loading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal));
        }

        // EXCEPTION HANDLER: "No Available Slots" UI
        if (provider.slotsState == LoadState.empty || slots.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondaryIce.withValues(alpha: 0.5),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primaryTeal, width: 2),
                        ),
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          size: 44,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('No Available Slots', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    _bookingMethod == BookingMethod.availableToday
                        ? 'No appointments are available today. Please try another booking method.'
                        : 'No appointments match your selected date or search.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySecondary,
                  ),
                ],
              ),
            ),
          );
        }

        // Slots Found List UI
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            Text(
              '${slots.length} Slots Found',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 12),
            ...slots.map((slot) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () {
                    setState(() {
                      _selectedSlot = slot;
                      _currentFlowStep = 2;
                    });
                  },
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.secondaryIce,
                        child: Icon(
                          _selectedType == AppointmentType.teleConsultation
                              ? Icons.video_call
                              : Icons.person,
                          color: AppColors.primaryTeal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(slot.doctorName, style: AppTextStyles.h3),
                            const Text('General Medicine',
                                style: AppTextStyles.caption),
                            const SizedBox(height: 2),
                            Text(slot.centerName,
                                style: AppTextStyles.bodySecondary),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                Text(
                                  MaterialLocalizations.of(context)
                                      .formatMediumDate(slot.slotDateTime),
                                  style: AppTextStyles.caption,
                                ),
                                Text(
                                  MaterialLocalizations.of(context)
                                      .formatTimeOfDay(
                                    TimeOfDay.fromDateTime(slot.slotDateTime),
                                  ),
                                  style: AppTextStyles.caption.copyWith(
                                      color: AppColors.primaryTeal,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppColors.primaryTeal),
                    ],
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  // --- Step 2: Details Review & Confirmation ---
  Widget _buildReviewDetailsSection(dynamic profile) {
    if (_selectedSlot == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please review the booking details below for your primary healthcare center appointment.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.secondaryIce,
                      child: Icon(
                        _selectedType == AppointmentType.teleConsultation
                            ? Icons.video_call
                            : Icons.person_outline,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedSlot!.doctorName,
                            style: AppTextStyles.h3),
                        const Text('Specialist - General Medicine',
                            style: AppTextStyles.caption),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildReviewDetailRow(
                  icon: Icons.location_on_outlined,
                  title: _selectedSlot!.centerName,
                  subtitle:
                      'Building 95, Lulu Road, Block 303, Manama, Bahrain',
                ),
                const SizedBox(height: 12),
                _buildReviewDetailRow(
                  icon: Icons.calendar_today_outlined,
                  title: MaterialLocalizations.of(context).formatMediumDate(
                    _selectedSlot!.slotDateTime,
                  ),
                  subtitle: _selectedType == AppointmentType.teleConsultation
                      ? 'Join link will be active 5 mins before slot'
                      : 'Arrive 15 minutes before your slot',
                ),
                const SizedBox(height: 12),
                _buildReviewDetailRow(
                  icon: Icons.access_time,
                  title: MaterialLocalizations.of(context).formatTimeOfDay(
                    TimeOfDay.fromDateTime(_selectedSlot!.slotDateTime),
                  ),
                  subtitle: 'Estimated duration: 15-20 mins',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Patient Information Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PATIENT DETAILS', style: AppTextStyles.caption),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Name', style: AppTextStyles.bodySecondary),
                    Text(profile?.fullName ?? 'Eman Al-Khalifa',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('CPR Number',
                        style: AppTextStyles.bodySecondary),
                    Text(profile?.cpr ?? '990422345',
                        style: AppTextStyles.body
                            .copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Confirm and Cancel Actions
          AppButton(
            label: 'Confirm Booking',
            isLoading: _isBooking,
            onPressed: _isBooking ? null : _confirmBooking,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Cancel',
              isOutlined: true,
              onPressed: () => setState(() => _currentFlowStep = 0),
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 3: Confirmation Ticket Pass ---
  Widget _buildBookingSuccessPassSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
                color: AppColors.success, shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          const Text('Booking Confirmed!', style: AppTextStyles.h2),
          const SizedBox(height: 20),

          // Appointment Pass Ticket
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('APPOINTMENT PASS', style: AppTextStyles.caption),
                    Text('APPROVED',
                        style: TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_selectedSlot?.doctorName ?? 'Dr. Fatima Al-Aali',
                    style: AppTextStyles.h3),
                const Text('Specialist - General Medicine',
                    style: AppTextStyles.caption),
                const SizedBox(height: 12),

                // Dashed Separator Line
                Row(
                  children: List.generate(
                    30,
                    (index) => Expanded(
                      child: Container(
                        height: 1,
                        color: index.isEven
                            ? AppColors.primaryTeal
                            : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CENTER', style: AppTextStyles.caption),
                        Text(_selectedSlot?.centerName ?? 'Naim HealthCenter',
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('CPR NUMBER', style: AppTextStyles.caption),
                        const Text('990422345',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('DATE & TIME', style: AppTextStyles.caption),
                        Text(
                            _selectedSlot == null
                                ? '-'
                                : '${MaterialLocalizations.of(context).formatMediumDate(_selectedSlot!.slotDateTime)}, '
                                    '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(_selectedSlot!.slotDateTime))}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('BOOKING ID', style: AppTextStyles.caption),
                        const Text('#NRK-2026-89',
                            style: TextStyle(
                                color: AppColors.primaryTeal,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'View My Appointments',
            onPressed: () => Navigator.pushNamed(context, '/appointments'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _currentFlowStep = 0),
            child: const Text('Back to Home',
                style: TextStyle(
                    color: AppColors.primaryTeal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Future<void> _confirmBooking() async {
    final selectedSlot = _selectedSlot;
    if (selectedSlot == null) return;

    setState(() => _isBooking = true);
    final success =
        await context.read<AppointmentProvider>().bookSlot(selectedSlot.id);
    if (!mounted) return;

    setState(() => _isBooking = false);
    if (success) {
      setState(() => _currentFlowStep = 3);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<AppointmentProvider>().errorMessage ??
                'This slot is no longer available.',
          ),
        ),
      );
    }
  }

  Widget _buildTypeSegment(AppointmentType type, String title, IconData icon) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryTeal : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.primaryTeal),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOptionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryTeal, size: 22),
          const SizedBox(width: 12),
          Expanded(
              child: Text(title,
                  style: AppTextStyles.body
                      .copyWith(fontWeight: FontWeight.w600))),
          const Icon(Icons.chevron_right, color: AppColors.primaryTeal),
        ],
      ),
    );
  }

  Widget _buildReviewDetailRow(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryTeal),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}
