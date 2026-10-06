import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widget/patient_sidebar.dart';
import '../find_doctors/view.dart';

class PatientHomeView extends StatefulWidget {
  const PatientHomeView({super.key});

  @override
  State<PatientHomeView> createState() => _PatientHomeViewState();
}

class _PatientHomeViewState extends State<PatientHomeView> {
  int selectedIndex = 0; // Dashboard active by default

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
                    });
                  },
                ),

                // Main Content Area
                Expanded(
                  child: Column(
                    children: [
                      // Top Header Bar
                      Container(
                        height: 70,
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                                color: Color(0xFFE2E8F0), width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              menuTitles[selectedIndex],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),

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

  // ================= MAIN CONTENT PLACEHOLDER =================
  Widget _buildMainContentArea() {
    if (selectedIndex == 1) {
      // Find Doctors View
      return const FindDoctorsView();
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
