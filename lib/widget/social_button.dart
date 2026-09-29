import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onMicroSoftTap;

  const SocialLoginButtons({
    super.key,
    required this.onGoogleTap,
    required this.onMicroSoftTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // ================= OR CONTINUE WITH =================
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.grey.shade300,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                "Or continue with",
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            Expanded(
              child: Divider(
                color: Colors.grey.shade300,
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),

        // ================= GOOGLE + FACEBOOK =================
        Column(
          children: [
            // Google
            _socialButton(
              imagePath: "assets/images/google1.png",
              text: "Google",
              onTap: onGoogleTap,
            ),

            const SizedBox(height: 10),

            // Facebook
            _socialButton(
              imagePath: "assets/images/img_2.png",
              text: "Facebook",
              onTap: onMicroSoftTap,
            ),
          ],
        ),
      ],
    );
  }

  // ================= SOCIAL BUTTON =================

  Widget _socialButton({
    required String imagePath,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 50,
      width: double.infinity, // Buttons ko full width karne ke liye
      child: ElevatedButton(
        onPressed: onTap,

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade100,
          foregroundColor: Colors.black87,
          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 40, // Size thora kam kiya
              width: 40,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Flexible( // Text ko flexible kiya taakay overflow na ho
              child: Text(
                text,
                overflow: TextOverflow.ellipsis, // Text zyada ho toh dots aa jayein
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
