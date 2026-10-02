
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../home/view.dart';

class DocHomeView extends StatefulWidget {
  const DocHomeView({super.key});

  @override
  State<DocHomeView> createState() => _DocHomeViewState();
}

class _DocHomeViewState extends State<DocHomeView> {
  int selectedIndex = 0;

  final List<String> menuTitles = [
    'Dashboard',
    'My Profile',
    'Appointments',
    'Patients',
    'Documents',
    'Availability',
    'Chat',
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
                // Persistent Doctor Sidebar on Web/Desktop
                _buildDoctorSidebar(context),

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
                        child: _buildMainContent(),
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
                child: _buildDoctorSidebar(context),
              ),
              body: _buildMainContent(),
            );
          }
        },
      ),
    );
  }

  // ================= MAIN CONTENT PLACEHOLDER =================
  Widget _buildMainContent() {
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

  // ================= DOCTOR SIDEBAR =================
  Widget _buildDoctorSidebar(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Container(
      width: 270,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // 1. Logo Header
          Padding(
            padding:
                const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 20),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/img.png',
                  height: 38,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.favorite_rounded,
                      color: Color(0xFF2563EB),
                      size: 32,
                    );
                  },
                ),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Health',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF1E1B4B),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: 'AI',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF2563EB),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Doctor Profile Card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/img_7.png',
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF2563EB),
                            size: 26,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currentUser?.displayName ?? 'Dr. Ahmed Khan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E1B4B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Cardiologist',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3. Navigation Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildMenuItem(
                  icon: Icons.home_rounded,
                  title: 'Dashboard',
                  index: 0,
                ),
                _buildMenuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'My Profile',
                  index: 1,
                ),
                _buildMenuItem(
                  icon: Icons.event_note_rounded,
                  title: 'Appointments',
                  index: 2,
                ),
                _buildMenuItem(
                  icon: Icons.people_outline_rounded,
                  title: 'Patients',
                  index: 3,
                ),
                _buildMenuItem(
                  icon: Icons.description_outlined,
                  title: 'Documents',
                  index: 4,
                ),
                _buildMenuItem(
                  icon: Icons.access_time_rounded,
                  title: 'Availability',
                  index: 5,
                ),
                _buildMenuItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Chat',
                  index: 6,
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  index: 7,
                ),
              ],
            ),
          ),

          // 4. Logout Item
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAll(() => const HomeScreen());
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      'Logout',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MENU ITEM =================
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFF64748B),
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

