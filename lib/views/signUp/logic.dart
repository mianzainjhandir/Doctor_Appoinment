import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webdocappoinment/views/home/view.dart';

class SignUpController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form Controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final doctorLicenseController = TextEditingController();

  // State Variables
  var isPatientSelected = true.obs;
  var isTermsAccepted = false.obs;
  var isLoading = false.obs;

  void toggleRole(bool isPatient) {
    isPatientSelected.value = isPatient;
  }

  void toggleTerms(bool? value) {
    isTermsAccepted.value = value ?? false;
  }

  // Sign Up Logic Function
  Future<void> signUpUser() async {
    final String fullName = fullNameController.text.trim();
    final String email = emailController.text.trim();
    final String phone = phoneController.text.trim();
    final String password = passwordController.text.trim();
    final String doctorLicense = doctorLicenseController.text.trim();

    // Validations
    if (fullName.isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter your full name",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

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

    if (phone.isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter your phone number",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        "Weak Password",
        "Password must be at least 6 characters long",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    if (!isPatientSelected.value && doctorLicense.isEmpty) {
      Get.snackbar(
        "Required",
        "Please enter your medical license number",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    if (!isTermsAccepted.value) {
      Get.snackbar(
        "Terms & Conditions",
        "Please accept the Terms & Conditions to proceed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // 1. Create User in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uid = userCredential.user!.uid;

      // Update Display Name in Firebase User Profile
      await userCredential.user?.updateDisplayName(fullName);

      // 2. Save User Data in Firestore Collection ("patient" or "doctor")
      final String collectionName =
          isPatientSelected.value ? "patient" : "doctor";

      Map<String, dynamic> userData = {
        "uid": uid,
        "fullName": fullName,
        "email": email,
        "phone": phone,
        "role": isPatientSelected.value ? "patient" : "doctor",
        "createdAt": FieldValue.serverTimestamp(),
      };

      if (!isPatientSelected.value) {
        userData["licenseNumber"] = doctorLicense;
      }

      await _firestore.collection(collectionName).doc(uid).set(userData);

      isLoading.value = false;

      Get.snackbar(
        "Success",
        "Account created successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
      );

      // Navigate to Home Page
      Get.offAll(() => const HomeScreen());
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      String message = "Sign up failed. Please try again.";

      if (e.code == 'email-already-in-use') {
        message = "This email address is already registered.";
      } else if (e.code == 'weak-password') {
        message = "The password provided is too weak.";
      } else if (e.code == 'invalid-email') {
        message = "The email address is invalid.";
      }

      Get.snackbar(
        "Authentication Error",
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

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    doctorLicenseController.dispose();
    super.onClose();
  }
}
