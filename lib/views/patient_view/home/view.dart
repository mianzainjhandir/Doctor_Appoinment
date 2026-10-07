import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widget/patient_sidebar.dart';
import '../appointments/view.dart';
import '../book_appointment/view.dart';
import '../chat/view.dart';
import '../dashboard/view.dart';
import '../doctor_detail/view.dart';
import '../documents/view.dart';
import '../find_doctors/view.dart';

class PatientHomeView extends StatefulWidget {
  const PatientHomeView({super.key});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
  int selectedIndex = 0; // Dashboard active by default
  Map<String, dynamic>? selectedDoctorData;
  Map<String, dynamic>? bookingDoctorData;

  final List<String> menuTitles = [
    'Dashboard',
    'Find Doctors',
    'Appointments',
    'Documents',
    'Chat',
    'Reminders',
    'History',
    'Profile',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 800;

          if (isWeb) {
            return Row(
              children: [
                // Persistent Patient Sidebar on Web/Desktop
                PatientSidebar(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                      selectedDoctorData = null;
                      bookingDoctorData = null;
                    });
                  },
                ),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Top Card Navigation Bar
                      _buildTopNavBar(context),

                      // Main Page Content
                      Expanded(
                        child: _buildMainContentArea(),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Mobile View with Drawer Sidebar
            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0.5,
                iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
                title: Text(
                  menuTitles[selectedIndex],
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              drawer: Drawer(
                child: PatientSidebar(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    Navigator.pop(context); // Close drawer
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),
              ),
              body: _buildMainContentArea(),
            );
          }
        },
      ),
    );
  }

  // ================= TOP CARD NAV BAR =================
  Widget _buildTopNavBar(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Logo
            Image.asset(
              'assets/images/img.png',
              height: 36,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.favorite_rounded,
                color: Color(0xFF2563EB),
                size: 30,
              ),
            ),
            const SizedBox(width: 8),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Health',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF1E1B4B),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'AI',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2563EB),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),

            // Center Nav Links
            _buildTopNavLink('Home', 0),
            const SizedBox(width: 24),
            _buildTopNavLink('Doctors', 1),
            const SizedBox(width: 24),
            _buildTopNavLink('Documents', 3),
            const SizedBox(width: 24),
            _buildTopNavLink('Chat', 4),

            const Spacer(),

            // Patient User Profile
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFFDBEAFE),
              child: const Icon(Icons.person_rounded,
                  color: Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              currentUser?.displayName ?? 'Aslam',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavLink(String label, int index) {
    final bool isSelected = selectedIndex == index &&
        selectedDoctorData == null &&
        bookingDoctorData == null;
    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
          selectedDoctorData = null;
          bookingDoctorData = null;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // ================= MAIN CONTENT PLACEHOLDER =================
  Widget _buildMainContentArea() {
    if (bookingDoctorData != null) {
      return BookAppointmentView(
        doctorData: bookingDoctorData!,
        onBack: () {
          setState(() {
            bookingDoctorData = null;
          });
        },
        onBookingSuccess: () {
          setState(() {
            bookingDoctorData = null;
            selectedDoctorData = null;
            selectedIndex = 2; // Switch to My Appointments tab
          });
        },
      );
    }

    if (selectedDoctorData != null) {
      return DoctorDetailView(
        doctorData: selectedDoctorData!,
        onBack: () {
          setState(() {
            selectedDoctorData = null;
          });
        },
        onBookAppointment: () {
          setState(() {
            bookingDoctorData = selectedDoctorData;
          });
        },
      );
    }

    if (selectedIndex == 0) {
      // Patient Dashboard View
      return PatientDashboardView(
        onNavigateTab: (tabIndex) {
          setState(() {
            selectedIndex = tabIndex;
            selectedDoctorData = null;
            bookingDoctorData = null;
          });
        },
        onDoctorSelected: (docData) {
          setState(() {
            selectedDoctorData = docData;
          });
        },
      );
    }

    if (selectedIndex == 1) {
      // Find Doctors View
      return FindDoctorsView(
        onDoctorSelected: (docData) {
          setState(() {
            selectedDoctorData = docData;
          });
        },
      );
    }

    if (selectedIndex == 2) {
      // Appointments View
      return const PatientAppointmentsView();
    }

    if (selectedIndex == 3) {
      // Documents View
      return const PatientDocumentsView();
    }

    if (selectedIndex == 4) {
      // Chat View
      return const PatientChatView();
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Center(
            child: Text(
              '${menuTitles[selectedIndex]} Content Area',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
