import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widget/doctor_sidebar.dart';
import '../add_doctor/view.dart';
import '../doctors_list/view.dart';

class DocHomeView extends StatefulWidget {
  const DocHomeView({super.key});

  @override
  State<DocHomeView> createState() => _DocHomeViewState();
}

class _DocHomeViewState extends State<DocHomeView> {
  int selectedIndex = 1; // "Doctors" active tab by default

  final List<String> menuTitles = [
    'Dashboard',
    'Doctors',
    'Add Doctor',
    'Appointments',
    'Patients',
    'Documents',
    'Messages',
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
                // Custom Doctor Sidebar Widget
                DoctorSidebar(
                  selectedIndex: selectedIndex,
                  onItemSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                ),

                // Main Content Body
                Expanded(
                  child: Column(
                    children: [
                      // Top Navigation Bar
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
                child: DoctorSidebar(
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

  // ================= MAIN CONTENT SWITCHER =================
  Widget _buildMainContentArea() {
    switch (selectedIndex) {
      case 1:
        // Doctors Directory List
        return DoctorsListView(
          onAddDoctorPressed: () {
            setState(() {
              selectedIndex = 2; // Switch to Add Doctor view
            });
          },
        );

      case 2:
        // Add Doctor Form View
        return AddDoctorView(
          onSuccess: () {
            setState(() {
              selectedIndex = 1; // Return to Doctors list after successful save
            });
          },
        );

      default:
        // Default Placeholder View for other menu tabs
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
}
