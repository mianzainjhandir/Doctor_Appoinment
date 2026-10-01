import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widget/social_button.dart';
import '../../widget/textfield.dart';
import '../signUp/view.dart';
import 'logic.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LogInController controller = Get.put(LogInController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 850;

          if (isWeb) {
            return Row(
              children: [
                // Left Section: Web Hero Branding & Illustration
                Expanded(
                  flex: 5,
                  child: _buildWebHeroSection(),
                ),

                // Right Section: Login Form
                Expanded(
                  flex: 5,
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 40),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 460),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 24,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildFormContent(context, controller, isWeb: true),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Mobile View
            return SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 440),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: _buildFormContent(context, controller, isWeb: false),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // ================= WEB LEFT HERO SECTION =================
  Widget _buildWebHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 50),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEFF6FF), // Soft light blue
            Color(0xFFDBEAFE), // Rich light blue
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Title
          Row(
            children: [
              Image.asset(
                'assets/images/img.png',
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFF2563EB),
                    size: 42,
                  );
                },
              ),
              const SizedBox(width: 12),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Health',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1E1B4B),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: 'AI',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF2563EB),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Heading
          Text(
            'Smart Healthcare & Appointment Management',
            style: GoogleFonts.poppins(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Book appointments with top doctors, manage your medical history, and get AI-powered health insights instantly.',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 30),

          // Illustration Image Showcase
          Expanded(
            child: Center(
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 330),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.asset(
                    'assets/images/img_6.png',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.health_and_safety_outlined,
                        size: 100,
                        color: Color(0xFF2563EB),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Feature Badges
          Row(
            children: [
              _buildFeaturePill('✨ Instant Booking'),
              const SizedBox(width: 12),
              _buildFeaturePill('🔒 Secure Records'),
              const SizedBox(width: 12),
              _buildFeaturePill('⚡ AI Diagnostics'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(220),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  // ================= FORM CONTENT =================
  Widget _buildFormContent(BuildContext context, LogInController controller,
      {required bool isWeb}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Button
        Row(
          children: [
            IconButton(
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Get.back();
                }
              },
              icon: const Icon(Icons.arrow_back, color: Color(0xFF334155)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 8),

        // Header Text & Mobile Logo
        Center(
          child: Column(
            children: [
              if (!isWeb) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/img.png',
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.favorite_rounded,
                          color: Color(0xFF2563EB),
                          size: 36,
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
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(
                            text: 'AI',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF2563EB),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],
              Text(
                'Welcome Back',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Login to your account to continue',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Role Switcher (Patient vs Admin/Doctor)
        Obx(() {
          final bool isPatientSelected = controller.isPatientSelected.value;
          return Container(
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                // Patient Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.toggleRole(true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isPatientSelected
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isPatientSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Patient',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: isPatientSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isPatientSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),

                // Admin / Doctor Tab
                Expanded(
                  child: GestureDetector(
                    onTap: () => controller.toggleRole(false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: !isPatientSelected
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !isPatientSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Admin / Doctor',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: !isPatientSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: !isPatientSelected
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 20),

        // Form Fields (Dynamic Label according to Role)
        Obx(() {
          final bool isPatient = controller.isPatientSelected.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPatient ? 'Email or Phone Number' : 'Doctor / Admin Email',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: controller.emailController,
                hintText: isPatient ? 'you@example.com' : 'doctor@healthai.com',
                prefixIcon: isPatient ? Icons.email_outlined : Icons.badge_outlined,
                keyboardType: TextInputType.emailAddress,
                focusColor: const Color(0xFF2563EB),
              ),
              const SizedBox(height: 16),
              Text(
                'Password',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: controller.passwordController,
                hintText: 'Enter your password',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                focusColor: const Color(0xFF2563EB),
              ),
            ],
          );
        }),

        const SizedBox(height: 10),

        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => controller.resetPassword(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Forgot password?',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Log In Submit Button
        Obx(() {
          final bool isLoading = controller.isLoading.value;
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => controller.loginUser(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Log In',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          );
        }),
        const SizedBox(height: 24),

        // Social Login Buttons
        SocialLoginButtons(
          onGoogleTap: () {},
          onMicroSoftTap: () {},
        ),
        const SizedBox(height: 20),

        // Footer Sign Up Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const SignUpPage());
              },
              child: Text(
                'Sign Up',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


