import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:flutterapp/consts/strings.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  String selectedRole = 'patient'; // Changed to lowercase for API consistency
  bool isLoading = false; // Add loading state
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController organDonationStatusController =
      TextEditingController();

  // Add base URL constant
  // final String baseUrl = 'http://192.168.0.106:4000/api/auth/register'; // Replace with your actual API base URL

  // Add signup function
  Future<void> signupCall() async {
    if (isLoading) return; // Prevent multiple submissions

    try {
      setState(() {
        isLoading = true; // Set loading state
      });

      // Basic validation
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        throw 'Please fill all required fields';
      }

      if (passwordController.text != confirmPasswordController.text) {
        throw 'Passwords do not match';
      }

      // Validate password length
      if (passwordController.text.length < 8) {
        throw 'Password must be at least 8 characters long';
      }

      // Prepare base user data
      Map<String, dynamic> userData = {
        'name': nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'userRole': selectedRole,
      };

      // Add role-specific data
      if (selectedRole == 'doctor') {
        if (specializationController.text.isEmpty) {
          throw 'Please enter specialization';
        }
        userData['specialization'] = specializationController.text;
      } else if (selectedRole == 'donor') {
        if (bloodTypeController.text.isEmpty ||
            organDonationStatusController.text.isEmpty) {
          throw 'Please select blood type and organ for donation';
        }
        userData['bloodType'] = bloodTypeController.text;
        userData['selectedOrgan'] = organDonationStatusController.text
            .split(',')
            .where((organ) => organ.isNotEmpty)
            .toList();
      }

      print('Sending signup request with data: ${json.encode(userData)}');

      // Make API call
      final response = await http.post(
        Uri.parse(Endpoints.register),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(userData),
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to login page
        Navigator.pop(context);
      } else {
        // Handle error response
        final errorData = json.decode(response.body);
        throw errorData['message'] ?? 'Signup failed';
      }
    } catch (e) {
      print('Error during signup: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Reset loading state
        });
      }
    }
  }

  // New function to clear form
  void clearForm() {
    // print("Clearing form");
    nameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    specializationController.clear();
    bloodTypeController.clear();
    organDonationStatusController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                "Create Account".text.bold.size(24).make(),
                20.heightBox,
                // Role Selection
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio(
                          value: 'patient',
                          groupValue: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value.toString();
                              clearForm();
                            });
                          },
                        ),
                        'Patient'.text.make(),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio(
                          value: 'doctor',
                          groupValue: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value.toString();
                              clearForm();
                            });
                          },
                        ),
                        'Doctor'.text.make(),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio(
                          value: 'donor',
                          groupValue: selectedRole,
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value.toString();
                              clearForm();
                            });
                          },
                        ),
                        'Donor'.text.make(),
                      ],
                    ),
                  ],
                ),
                20.heightBox,
                Form(
                  child: Column(
                    children: [
                      CustomTextField(
                        hint: "Full Name",
                        prefixIcon: Icons.person,
                        textController: nameController,
                      ),
                      10.heightBox,
                      CustomTextField(
                        hint: AppStrings.emailHint,
                        prefixIcon: Icons.email,
                        textController: emailController,
                      ),
                      10.heightBox,
                      CustomTextField(
                        hint: AppStrings.passwordHint,
                        prefixIcon: Icons.lock,
                        isPassword: true,
                        textController: passwordController,
                        // hint: 'Password must be at least 8 characters long',
                      ),
                      10.heightBox,
                      CustomTextField(
                        hint: "Confirm Password",
                        prefixIcon: Icons.lock,
                        isPassword: true,
                        textController: confirmPasswordController,
                      ),
                      if (selectedRole == 'doctor') ...[
                        10.heightBox,
                        CustomTextField(
                          hint: "Specialization",
                          prefixIcon: Icons.work,
                          textController: specializationController,
                        ),
                      ],
                      if (selectedRole == 'donor') ...[
                        10.heightBox,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.bloodtype),
                            ),
                            hint: const Text('Select Blood Type'),
                            value: bloodTypeController.text.isEmpty
                                ? null
                                : bloodTypeController.text,
                            items: [
                              'A+',
                              'A-',
                              'B+',
                              'B-',
                              'AB+',
                              'AB-',
                              'O+',
                              'O-'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                bloodTypeController.text = value ?? '';
                              });
                            },
                          ),
                        ),
                        10.heightBox,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.volunteer_activism),
                            ),
                            hint: const Text('Select Organs for Donation'),
                            value: null,
                            items: [
                              'Kidney',
                              'Liver',
                              'Heart',
                              'Lungs',
                              'Pancreas',
                              'Small Bowel'
                            ].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  List<String> currentOrgans =
                                      organDonationStatusController.text
                                          .split(',')
                                          .where((organ) => organ.isNotEmpty)
                                          .toList();

                                  if (!currentOrgans.contains(newValue)) {
                                    currentOrgans.add(newValue);
                                  }

                                  organDonationStatusController.text =
                                      currentOrgans.join(',');
                                });
                              }
                            },
                          ),
                        ),
                        if (organDonationStatusController.text.isNotEmpty) ...[
                          10.heightBox,
                          Container(
                            constraints: const BoxConstraints(maxHeight: 100),
                            child: SingleChildScrollView(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: organDonationStatusController.text
                                    .split(',')
                                    .where((organ) => organ.isNotEmpty)
                                    .map((organ) => Chip(
                                          label: Text(organ),
                                          onDeleted: () {
                                            setState(() {
                                              List<String> organs =
                                                  organDonationStatusController
                                                      .text
                                                      .split(',')
                                                      .where(
                                                          (o) => o.isNotEmpty)
                                                      .toList();
                                              organs.remove(organ);
                                              organDonationStatusController
                                                  .text = organs.join(',');
                                            });
                                          },
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ],
                      20.heightBox,
                      CustomButton(
                        buttonText: isLoading ? "Signing Up..." : "Sign Up",
                        onTap: isLoading
                            ? null
                            : () async {
                                await signupCall();
                              },
                      ),
                      20.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          "Already have an account? ".text.make(),
                          "Login".text.color(Colors.blue).make().onTap(() {
                            Navigator.pop(context);
                          })
                        ],
                      ),
                      const SizedBox(height: 20), // Add bottom padding
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose is for cleaning up resources when widget is destroyed
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    specializationController.dispose();
    bloodTypeController.dispose();
    organDonationStatusController.dispose();
    super.dispose();
  }
}
