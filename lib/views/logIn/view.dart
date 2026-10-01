import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widget/social_button.dart';
import '../../widget/textfield.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool isPatientSelected = true;

  final TextEditingController patientEmailController = TextEditingController();
  final TextEditingController patientPasswordController = TextEditingController();

  final TextEditingController adminEmailController = TextEditingController();
  final TextEditingController adminPasswordController = TextEditingController();

  @override
  void dispose() {
    patientEmailController.dispose();
    patientPasswordController.dispose();
    adminEmailController.dispose();
    adminPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
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

                  // Logo & Welcome Header
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/img.png',
                              height: 42,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.favorite_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 38,
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
                        const SizedBox(height: 16),
                        Text(
                          'Welcome Back',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
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
                  Container(
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
                            onTap: () {
                              setState(() {
                                isPatientSelected = true;
                              });
                            },
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
                            onTap: () {
                              setState(() {
                                isPatientSelected = false;
                              });
                            },
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
                  ),
                  const SizedBox(height: 20),

                  // Conditional Fields based on Selected Role
                  if (isPatientSelected) ...[
                    // PATIENT FORM FIELDS
                    Text(
                      'Email or Phone Number',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: patientEmailController,
                      hintText: 'you@example.com',
                      prefixIcon: Icons.email_outlined,
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
                      controller: patientPasswordController,
                      hintText: 'Enter your password',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      focusColor: const Color(0xFF2563EB),
                    ),
                  ] else ...[
                    // ADMIN FORM FIELDS
                    Text(
                      'Admin / Doctor ID or Email',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: adminEmailController,
                      hintText: 'admin@healthai.com or ID',
                      prefixIcon: Icons.badge_outlined,
                      keyboardType: TextInputType.emailAddress,
                      focusColor: const Color(0xFF2563EB),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Admin Password',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: adminPasswordController,
                      hintText: 'Enter admin passcode',
                      prefixIcon: Icons.admin_panel_settings_outlined,
                      isPassword: true,
                      focusColor: const Color(0xFF2563EB),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
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

                  // Submit Log In Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Log In',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Social Buttons
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
                        onTap: () {},
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
              ),
            ),
          ),
        ),
      ),
    );
  }
}

