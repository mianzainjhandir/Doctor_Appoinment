
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widget/textfield.dart';
import '../logIn/view.dart';
import 'logic.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SignUpController controller = Get.put(SignUpController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWeb = constraints.maxWidth > 850;

          if (isWeb) {
            return Row(
              children: [
                // Left Web Hero Column
                Expanded(
                  flex: 5,
                  child: _buildWebHeroSection(),
                ),

                // Right Form Column
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

  // ================= WEB HERO SECTION =================
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
          // Brand Logo
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
          const SizedBox(height: 36),

          // Heading
          Text(
            'Join HealthAI & Transform Your Healthcare Experience',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Create your account to book appointments, consult with top specialists, and access AI-driven medical insights anytime, anywhere.',
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 30),

          // Showcase Illustration Card
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
                    'assets/images/img_5.png',
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
              _buildFeaturePill('✨ Fast Sign Up'),
              const SizedBox(width: 12),
              _buildFeaturePill('🔒 100% Confidential'),
              const SizedBox(width: 12),
              _buildFeaturePill('⚡ AI Powered'),
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
  Widget _buildFormContent(BuildContext context, SignUpController controller,
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
                'Create Your Account',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Join us for a healthier tomorrow',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Role Switcher Tabs (Patient vs Doctor)
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

                // Doctor Tab
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
                        'Doctor',
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

        // Full Name Field
        Text(
          'Full Name',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.fullNameController,
          hintText: 'Enter your full name',
          prefixIcon: Icons.person_outline_rounded,
          focusColor: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),

        // Email Field
        Text(
          'Email',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.emailController,
          hintText: 'you@example.com',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          focusColor: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),

        // Phone Number Field
        Text(
          'Phone Number',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller.phoneController,
          hintText: '+92 300 1234567',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          focusColor: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),

        // Doctor License Field (If Doctor Role Selected)
        Obx(() {
          if (!controller.isPatientSelected.value) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical License / Reg Number',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: controller.doctorLicenseController,
                  hintText: 'e.g. PMC-123456',
                  prefixIcon: Icons.badge_outlined,
                  focusColor: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 16),
              ],
            );
          }
          return const SizedBox.shrink();
        }),

        // Password Field
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
          hintText: 'Create a password',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          focusColor: const Color(0xFF2563EB),
        ),
        const SizedBox(height: 16),

        // Terms & Conditions Checkbox
        Obx(() {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: controller.isTermsAccepted.value,
                  activeColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (value) => controller.toggleTerms(value),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  children: [
                    Text(
                      'I agree to the ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Terms & Conditions ',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    Text(
                      'and ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Privacy Policy',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        const SizedBox(height: 24),

        // Create Account Action Button
        Obx(() {
          final bool isLoading = controller.isLoading.value;
          return SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : () => controller.signUpUser(),
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
                      'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          );
        }),
        const SizedBox(height: 24),

        // Footer Navigation to Log In
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Already have an account? ",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF64748B),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => const LogInPage());
              },
              child: Text(
                'Log In',
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


