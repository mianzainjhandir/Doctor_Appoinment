import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webdocappoinment/views/doctor_views/home/view.dart';
import 'package:webdocappoinment/views/patient_view/home/view.dart';

class LogInController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State
  var isPatientSelected = true.obs;
  var isLoading = false.obs;

  void toggleRole(bool isPatient) {
    isPatientSelected.value = isPatient;
  }

  Future<void> loginUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        "Invalid Email",
        "Please enter a valid email address",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter your password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 1. Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      // 2. Check Role in Firestore Database
      if (isPatientSelected.value) {
        // Checking "patient" collection
        DocumentSnapshot patientDoc =
            await _firestore.collection("patient").doc(uid).get();

        if (patientDoc.exists) {
          isLoading.value = false;
          Get.snackbar(
            "Welcome Back",
            "Login successful!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
          );
          // Navigate to Patient Home View
          Get.offAll(() => const PatientHomeView());
        } else {
          // Check if registered as Doctor
          DocumentSnapshot docDoc =
              await _firestore.collection("doctor").doc(uid).get();
          isLoading.value = false;

          if (docDoc.exists) {
            Get.snackbar(
              "Account Mismatch",
              "This account is registered as a Doctor. Please select Doctor login.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.shade800,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              "Error",
              "No patient profile found for this account.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade400,
              colorText: Colors.white,
            );
          }
        }
      } else {
        // Checking "doctor" collection
        DocumentSnapshot doctorDoc =
            await _firestore.collection("doctor").doc(uid).get();

        if (doctorDoc.exists) {
          isLoading.value = false;
          Get.snackbar(
            "Welcome Back",
            "Doctor login successful!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade600,
            colorText: Colors.white,
          );
          // Navigate to Doctor Home View
          Get.offAll(() => const DocHomeView());
        } else {
          // Check if registered as Patient
          DocumentSnapshot patientDoc =
              await _firestore.collection("patient").doc(uid).get();
          isLoading.value = false;

          if (patientDoc.exists) {
            Get.snackbar(
              "Account Mismatch",
              "This account is registered as a Patient. Please select Patient login.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.shade800,
              colorText: Colors.white,
            );
          } else {
            Get.snackbar(
              "Error",
              "No doctor profile found for this account.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade400,
              colorText: Colors.white,
            );
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = "Login failed. Please check your credentials.";

      if (e.code == 'user-not-found') {
        message = "No account found with this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password. Please try again.";
      } else if (e.code == 'invalid-credential') {
        message = "Invalid email or password.";
      }

      Get.snackbar(
        "Login Error",
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "An unexpected error occurred: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  // Reset Password
  Future<void> resetPassword() async {
    final String email = emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        "Required",
        "Please enter your email address to reset password",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        "Reset Link Sent",
        "Password reset link has been sent to $email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send reset link: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
