
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webdocappoinment/views/logIn/view.dart';
import 'package:webdocappoinment/views/signUp/view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedMenu = 'Home';

  final List<String> navItems = [
    'Home',
    'Doctors',
    'Features',
    'About',
    'Contact',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90), // Yahan se height badhai ja sakti hai (e.g. 80, 90, 100)
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Logo Image & HealthAI Text together in a Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/img.png', // Aapki image ka path yahan aayega
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0x1A2563EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Logo Path Here",
                              style: TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                color: Colors.black,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: 'AI',
                              style: GoogleFonts.poppins(
                                color: Colors.deepPurple,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 2. Features / Navigation Links (Home, Doctors, Features, About, Contact)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: navItems.map((item) {
                      final isSelected = selectedMenu == item;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              selectedMenu = item;
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            child: Text(
                              item,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFF4B5563),
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // 3. Action Buttons (Login & Sign Up)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Login Button
                      OutlinedButton(
                        onPressed: () {
                          Get.to(()=> LogInPage());
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Sign Up Button
                      ElevatedButton(
                        onPressed: () {
                          Get.to(() => const SignUpPage());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF0F6FF),
                Color(0xFFF8FAFC),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    bool isWide = constraints.maxWidth > 850;

                    Widget leftContent = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1. Badge Pill
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDBEAFE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF2563EB),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AI-Powered Healthcare Platform',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF2563EB),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 2. Main Heading Title
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              fontSize: isWide ? 42 : 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              color: const Color(0xFF0F172A),
                            ),
                            children: [
                              const TextSpan(
                                  text: 'Book Doctors, Manage Health,\nWith the Power of '),
                              TextSpan(
                                text: 'AI',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF6366F1),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // 3. Subtitle / Description Text
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 540),
                          child: Text(
                            'Find the right doctor, book appointments, manage your medical documents, get smart AI summaries and stay connected — all in one place.',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: const Color(0xFF64748B),
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // 4. Search Bar Container
                        Container(
                          constraints: const BoxConstraints(maxWidth: 580),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0F000000),
                                blurRadius: 20,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Search Doctor Field
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    const SizedBox(width: 8),
                                    const Icon(Icons.search,
                                        color: Color(0xFF64748B), size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Search doctor, specialty...',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF94A3B8),
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Vertical Divider
                              Container(
                                height: 28,
                                width: 1,
                                color: const Color(0xFFE2E8F0),
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                              ),

                              // Location Field
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        color: Color(0xFF64748B), size: 20),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Lahore, Pakistan',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF334155),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down,
                                        color: Color(0xFF64748B), size: 18),
                                    const SizedBox(width: 4),
                                  ],
                                ),
                              ),

                              // Search Button
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3B82F6),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 16),
                                ),
                                child: Text(
                                  'Search',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );

                    Widget rightImage = Container(
                      constraints: BoxConstraints(
                        maxHeight: isWide ? 460 : 360,
                      ),
                      child: Image.asset(
                        "assets/images/img_1.png",
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 350,
                            width: 400,
                            decoration: BoxDecoration(
                              color: const Color(0xFFDBEAFE),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Text("Image Path: assets/images/img_1.png"),
                            ),
                          );
                        },
                      ),
                    );

                    if (isWide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 6, child: leftContent),
                          const SizedBox(width: 30),
                          Expanded(flex: 5, child: rightImage),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          leftContent,
                          const SizedBox(height: 40),
                          rightImage,
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 50),

                // Features Banner Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x08000000),
                        blurRadius: 15,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 32,
                    runSpacing: 20,
                    alignment: WrapAlignment.spaceAround,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.calendar_month_rounded,
                        iconColor: const Color(0xFF6366F1),
                        bgColor: const Color(0xFFEEF2FF),
                        title: 'Book Appointments',
                        subtitle: 'Easy & Fast',
                      ),
                      _buildFeatureCard(
                        icon: Icons.description_outlined,
                        iconColor: const Color(0xFF10B981),
                        bgColor: const Color(0xFFECFDF5),
                        title: 'Upload Documents',
                        subtitle: 'Get AI Summaries',
                      ),
                      _buildFeatureCard(
                        icon: Icons.chat_bubble_outline_rounded,
                        iconColor: const Color(0xFF2563EB),
                        bgColor: const Color(0xFFEFF6FF),
                        title: 'Chat with Doctors',
                        subtitle: 'Directly & Securely',
                      ),
                      _buildFeatureCard(
                        icon: Icons.notifications_none_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        bgColor: const Color(0xFFF0F9FF),
                        title: 'Reminders',
                        subtitle: 'Never Miss Again',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Popular Specialties Section
                _buildPopularSpecialtiesSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSpecialtiesSection() {
    final List<Map<String, dynamic>> specialties = [
      {
        'title': 'General Physician',
        'icon': Icons.person_outline_rounded,
        'bgColor': const Color(0xFFEFF6FF),
        'iconColor': const Color(0xFF2563EB),
      },
      {
        'title': 'Cardiologist',
        'icon': Icons.favorite_border_rounded,
        'bgColor': const Color(0xFFFEE2E2),
        'iconColor': const Color(0xFFDC2626),
      },
      {
        'title': 'Dermatologist',
        'icon': Icons.clean_hands_outlined,
        'bgColor': const Color(0xFFE0F2FE),
        'iconColor': const Color(0xFF0284C7),
      },
      {
        'title': 'Pediatrician',
        'icon': Icons.child_care_rounded,
        'bgColor': const Color(0xFFFEF3C7),
        'iconColor': const Color(0xFFD97706),
      },
      {
        'title': 'Gynecologist',
        'icon': Icons.female_rounded,
        'bgColor': const Color(0xFFF3E8FF),
        'iconColor': const Color(0xFF7C3AED),
      },
      {
        'title': 'Orthopedic',
        'icon': Icons.align_horizontal_left_rounded,
        'bgColor': const Color(0xFFDCFCE7),
        'iconColor': const Color(0xFF16A34A),
      },
      {
        'title': 'Neurologist',
        'icon': Icons.psychology_outlined,
        'bgColor': const Color(0xFFE0E7FF),
        'iconColor': const Color(0xFF4F46E5),
      },
      {
        'title': 'More',
        'icon': Icons.show_chart_rounded,
        'bgColor': const Color(0xFFF1F5F9),
        'iconColor': const Color(0xFF64748B),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Specialties',
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E1B4B),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            InkWell(
              onTap: () {
                Get.to(() => LogInPage());
              },
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2563EB),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF2563EB),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Specialty Cards Row
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: specialties.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = specialties[index];
              return _buildSpecialtyCard(
                title: item['title'] as String,
                icon: item['icon'] as IconData,
                iconColor: item['iconColor'] as Color,
                bgColor: item['bgColor'] as Color,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialtyCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return InkWell(
      onTap: () {
        Get.to(() => LogInPage());
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: const Color(0xFF1E1B4B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// today 3 times commited code but showing 0.
// testing that commit or push is working or not.