// lib/screens/booking/booking_appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../models/appointment.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

enum BookingView {
  chooseMethod,
  bookByDateDoctor,
  availableToday,
  closestSlot,
  reviewDetails,
  bookingSuccess,
}

class BookingAppointmentScreen extends StatefulWidget {
  const BookingAppointmentScreen({super.key});

  @override
  State<BookingAppointmentScreen> createState() =>
      _BookingAppointmentScreenState();
}

class _BookingAppointmentScreenState extends State<BookingAppointmentScreen> {
  BookingView _currentView = BookingView.chooseMethod;

  // Form State for "Book by Date & Doctor"
  String? _selectedDoctor;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  String? _selectedSlotId;

  // Search & Filter state for Available Today / Closest Slot
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenderFilter = 'All';
  String _selectedSortTime = 'Ascending';
  Appointment? _confirmedAppointment;
  bool _isBooking = false;

  final List<String> _mockDoctors = [
    'Dr. Fatima Al-Dosari',
    'Dr. Khalid Al-Mansoori',
    'Dr. Hind Al-Zayani',
    'Dr. Mohamed Al-Ansari',
    'Dr. Sara Al-Rumaihi',
  ];

  final List<String> _mockTimeSlots = [
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '11:00',
  ];

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

  void _handleBack() {
    setState(() {
      if (_currentView == BookingView.reviewDetails) {
        _currentView = BookingView.bookByDateDoctor;
      } else if (_currentView != BookingView.chooseMethod &&
          _currentView != BookingView.bookingSuccess) {
        _currentView = BookingView.chooseMethod;
      }
    });
  }

  String _getAppBarTitle() {
    switch (_currentView) {
      case BookingView.chooseMethod:
        return 'Choose Booking Method';
      case BookingView.bookByDateDoctor:
        return 'Book by Date & Doctor';
      case BookingView.availableToday:
        return 'Available Today';
      case BookingView.closestSlot:
        return 'Closest Available Slot';
      case BookingView.reviewDetails:
        return 'Confirm Booking';
      case BookingView.bookingSuccess:
        return 'Booking Success';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = context.watch<AppSettingsProvider>().palette.primary;
    final userProfile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      appBar: AppTopBar(
        title: _getAppBarTitle(),
        showBackButton: _currentView != BookingView.chooseMethod &&
            _currentView != BookingView.bookingSuccess,
        onBack: _handleBack,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildCurrentScreenView(themeColor, userProfile),
        ),
      ),
      bottomNavigationBar: _buildGlobalBottomNav(themeColor),
    );
  }

  Widget _buildCurrentScreenView(Color themeColor, dynamic profile) {
    switch (_currentView) {
      case BookingView.chooseMethod:
        return _buildScreen1ChooseMethod(themeColor);
      case BookingView.bookByDateDoctor:
        return _buildScreen2BookByDateDoctor(themeColor, profile);
      case BookingView.availableToday:
        return _buildScreen3AvailableToday(themeColor);
      case BookingView.closestSlot:
        return _buildScreen4ClosestSlot(themeColor);
      case BookingView.reviewDetails:
        return _buildReviewDetailsView(themeColor, profile);
      case BookingView.bookingSuccess:
        return _buildSuccessPassView(themeColor);
    }
  }

  // ==========================================
  // SCREEN 1: CHOOSE BOOKING METHOD
  // ==========================================
  Widget _buildScreen1ChooseMethod(Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'How would you like to book?',
              style: AppTextStyles.bodySecondary.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildMethodCard(
            themeColor: themeColor,
            icon: Icons.calendar_month_outlined,
            title: 'By date & doctor',
            description: 'Choose a specific doctor and date',
            onTap: () {
              setState(() => _currentView = BookingView.bookByDateDoctor);
            },
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            themeColor: themeColor,
            icon: Icons.access_time_rounded,
            title: 'Available today',
            description: 'See who can see you today',
            onTap: () {
              setState(() => _currentView = BookingView.availableToday);
            },
          ),
          const SizedBox(height: 16),
          _buildMethodCard(
            themeColor: themeColor,
            icon: Icons.bolt_outlined,
            title: 'Closest Available Slot',
            description: 'Soonest available appointment anywhere',
            onTap: () {
              setState(() => _currentView = BookingView.closestSlot);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMethodCard({
    required Color themeColor,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.ink100, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: themeColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.h3.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.ink500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: themeColor.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 2: BOOK BY DATE & DOCTOR
  // ==========================================
  Widget _buildScreen2BookByDateDoctor(Color themeColor, dynamic profile) {
    final healthCenter = profile?.assignedHealthCenter ?? 'Naim Health Center';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Health Center Label & Field
          Text('Health Center', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.ink100.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.ink050),
            ),
            child: Text(
              '$healthCenter (auto-filled)',
              style: AppTextStyles.body.copyWith(color: AppColors.ink500),
            ),
          ),
          const SizedBox(height: 20),

          // Doctor Selection Dropdown
          Text('Doctor', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _selectedDoctor,
            hint: const Text('[Select doctor]'),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.ink050),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.ink050),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: themeColor, width: 2),
              ),
            ),
            items: _mockDoctors.map((doc) {
              return DropdownMenuItem(value: doc, child: Text(doc));
            }).toList(),
            onChanged: (val) => setState(() => _selectedDoctor = val),
          ),
          const SizedBox(height: 20),

          // Date Selection Calendar
          Text('SELECT DATE', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.ink100),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
              onDateChanged: (date) => setState(() => _selectedDate = date),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              'Selected date: ${MaterialLocalizations.of(context).formatFullDate(_selectedDate)}',
              style: AppTextStyles.body.copyWith(color: themeColor, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 24),

          // Available Time Slots Section
          Text('AVAILABLE TIME SLOTS', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.3,
            ),
            itemCount: _mockTimeSlots.length,
            itemBuilder: (context, idx) {
              final slot = _mockTimeSlots[idx];
              final isSelected = _selectedTimeSlot == slot;

              return InkWell(
                onTap: () => setState(() => _selectedTimeSlot = slot),
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? themeColor : AppColors.ink050,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      slot,
                      style: AppTextStyles.body.copyWith(
                        color: isSelected ? Colors.white : AppColors.neutralDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // Continue Button
          AppButton(
            label: 'Continue',
            onPressed: (_selectedDoctor != null && _selectedTimeSlot != null)
                ? () {
                    setState(() {
                      _currentView = BookingView.reviewDetails;
                    });
                  }
                : null,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================
  // SCREEN 3: AVAILABLE TODAY
  // ==========================================
  Widget _buildScreen3AvailableToday(Color themeColor) {
    final slots = context.watch<AppointmentProvider>().availableSlots.where((slot) {
      final matchesGender = _selectedGenderFilter == 'All' ||
          slot.doctorGender?.toLowerCase() == _selectedGenderFilter.toLowerCase();
      return matchesGender && slot.doctorName.toLowerCase().contains(_searchController.text.toLowerCase());
    }).toList()
      ..sort((a, b) => _selectedSortTime == 'Ascending'
          ? a.slotDateTime.compareTo(b.slotDateTime)
          : b.slotDateTime.compareTo(a.slotDateTime));
    return Column(
      children: [
        // Search & Filter Header Section
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  prefixIcon: Icon(Icons.search_rounded, color: themeColor),
                  filled: true,
                  fillColor: AppColors.ink100.withValues(alpha: 0.5),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFilterChip('Gender: $_selectedGenderFilter', themeColor, () {
                    _showGenderFilterModal(themeColor);
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Time: $_selectedSortTime', themeColor, () {
                    _showTimeSortModal(themeColor);
                  }),
                ],
              ),
            ],
          ),
        ),

        // Doctors Cards List
        Expanded(
          child: slots.isEmpty
              ? const Center(child: Text('No available doctors match these filters.'))
              : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: slots.map((slot) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildDoctorTodayCard(
                doctorName: '${slot.doctorName} (${slot.doctorGender ?? 'Not specified'})',
                themeColor: themeColor,
                slots: [MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(slot.slotDateTime))],
                onSelected: () => setState(() {
                  _selectedDoctor = slot.doctorName;
                  _selectedTimeSlot = MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(slot.slotDateTime));
                  _selectedDate = slot.slotDateTime;
                  _selectedSlotId = slot.id;
                  _currentView = BookingView.reviewDetails;
                }),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorTodayCard({
    required String doctorName,
    required Color themeColor,
    required List<String> slots,
    VoidCallback? onSelected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(doctorName, style: AppTextStyles.h3.copyWith(fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: slots.map((slot) {
              final isSelected = _selectedDoctor == doctorName && _selectedTimeSlot == slot;
              return InkWell(
                onTap: onSelected ?? () {
                  setState(() {
                    _selectedDoctor = doctorName;
                    _selectedTimeSlot = slot;
                    _selectedDate = DateTime.now();
                    _currentView = BookingView.reviewDetails;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? themeColor : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isSelected ? themeColor : AppColors.ink500),
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.neutralDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SCREEN 4: CLOSEST AVAILABLE SLOT
  // ==========================================
  Widget _buildScreen4ClosestSlot(Color themeColor) {
    final closestSlots = context.watch<AppointmentProvider>().availableSlots
        .where((slot) => _selectedGenderFilter == 'All' || slot.doctorGender == _selectedGenderFilter)
        .map((slot) => <String, String>{
              'doctor': slot.doctorName,
              'time': '${MaterialLocalizations.of(context).formatMediumDate(slot.slotDateTime)} · ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(slot.slotDateTime))}',
              'id': slot.id,
            })
        .toList();
    return Column(
      children: [
        // Sorting Header Options
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              _buildFilterChip('Name', themeColor, () {}),
              const SizedBox(width: 8),
              _buildFilterChip('Gender: $_selectedGenderFilter', themeColor, () => _showGenderFilterModal(themeColor)),
              const SizedBox(width: 8),
              _buildFilterChip('Time', themeColor, () => _showTimeSortModal(themeColor)),
            ],
          ),
        ),

        // List of Closest Available Doctor Slots
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: closestSlots.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final item = closestSlots[idx];
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.ink100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['doctor']!,
                            style: AppTextStyles.h3.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['time']!,
                            style: AppTextStyles.caption.copyWith(
                              color: themeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedDoctor = item['doctor'];
                          _selectedTimeSlot = item['time']!.split(' ')[0];
                          _selectedDate = DateTime.now();
                          _selectedSlotId = item['id'];
                          _currentView = BookingView.reviewDetails;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: themeColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      ),
                      child: Text(
                        'Select',
                        style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // REVIEW DETAILS SECTION
  // ==========================================
  Widget _buildReviewDetailsView(Color themeColor, dynamic profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Appointment Details',
            style: AppTextStyles.h2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.ink100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(Icons.person_outline, 'Doctor', _selectedDoctor ?? 'Dr. Fatima Al-Dosari', themeColor),
                const Divider(height: 24),
                _buildSummaryRow(Icons.location_on_outlined, 'Health Center', profile?.assignedHealthCenter ?? 'Naim Health Center', themeColor),
                const Divider(height: 24),
                _buildSummaryRow(
                  Icons.calendar_today_rounded,
                  'Date & Time',
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} at ${_selectedTimeSlot ?? '09:30 AM'}',
                  themeColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'Confirm Booking',
            isLoading: _isBooking,
            onPressed: () async {
              setState(() => _isBooking = true);
              final provider = context.read<AppointmentProvider>();
              final slotId = _selectedSlotId ??
                  (provider.availableSlots.isNotEmpty ? provider.availableSlots.first.id : null);
              if (slotId == null) {
                setState(() => _isBooking = false);
                return;
              }
              final success = await provider.bookSlot(slotId);
              setState(() => _isBooking = false);
              if (success) {
                setState(() {
                  _confirmedAppointment = provider.myAppointments.last;
                  _currentView = BookingView.bookingSuccess;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SUCCESS PASS TICKET SECTION
  // ==========================================
  Widget _buildSuccessPassView(Color themeColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text('Booking Confirmed!', style: AppTextStyles.h2),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: themeColor.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('APPOINTMENT PASS', style: AppTextStyles.caption),
                    Text(
                      'APPROVED',
                      style: TextStyle(
                        color: themeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedDoctor ?? 'Dr. Fatima Al-Dosari',
                  style: AppTextStyles.h3.copyWith(fontSize: 18),
                ),
                const Text('Specialist - Family Medicine', style: AppTextStyles.caption),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(
                    24,
                    (i) => Expanded(
                      child: Container(
                        height: 1.5,
                        color: i.isEven ? themeColor : Colors.transparent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('DATE & TIME', style: AppTextStyles.caption),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} - ${_selectedTimeSlot ?? '09:30 AM'}',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          AppButton(
            label: 'View My Appointments',
            onPressed: () => Navigator.pushNamed(context, '/appointments'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            child: Text(
              'Back to Home',
              style: TextStyle(color: themeColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // GLOBAL UI HELPERS & COMPONENTS
  // ==========================================
  Widget _buildFilterChip(String label, Color themeColor, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
        ],
      ),
      backgroundColor: Colors.white,
      side: const BorderSide(color: AppColors.ink500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String val, Color themeColor) {
    return Row(
      children: [
        Icon(icon, color: themeColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(val, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  void _showGenderFilterModal(Color themeColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['All', 'Female', 'Male'].map((g) {
              return ListTile(
                title: Text(g),
                trailing: _selectedGenderFilter == g ? Icon(Icons.check, color: themeColor) : null,
                onTap: () {
                  setState(() => _selectedGenderFilter = g);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showTimeSortModal(Color themeColor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['Ascending', 'Descending'].map((t) {
              return ListTile(
                title: Text(t),
                trailing: _selectedSortTime == t ? Icon(Icons.check, color: themeColor) : null,
                onTap: () {
                  setState(() => _selectedSortTime = t);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // Unified Application Bottom Navigation Bar
  Widget _buildGlobalBottomNav(Color themeColor) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.ink100, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: 1, // Appointments Tab Active
        selectedItemColor: themeColor,
        unselectedItemColor: AppColors.ink500,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              setState(() => _currentView = BookingView.chooseMethod);
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/services-tab');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today_rounded), label: 'Appts'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view_rounded), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}
