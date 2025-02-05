import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/consts/strings.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';


class SignupView extends StatefulWidget {
  const SignupView({super.key});

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  String selectedRole = 'patient'; // Changed to lowercase for API consistency
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController organDonationStatusController = TextEditingController();

//   Future<void> signupCall() async {
//     try {
//       final userData = {
//         'name': nameController.text,

//       'email': emailController.text,
//       'password': passwordController.text,
//     };
//   }catch(e){
//     print('Error during signup: $e');
//   }
// }

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
                            items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              bloodTypeController.text = value ?? '';
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
                            hint: const Text('Select Organ for Donation'),
                            items: ['Kidney', 'Liver', 'Heart', 'Lungs', 'Pancreas', 'Small Bowel']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              organDonationStatusController.text = value ?? '';
                            },
                          ),
                        ),
                      ],
                      20.heightBox,
                      CustomButton(
                        buttonText: "Sign Up",
                        onTap: () async {
                          try {
                            final userData = {
                              'name': nameController.text,
                              'email': emailController.text,
                              'password': passwordController.text,
                              'role': selectedRole,
                              if (selectedRole == 'doctor')
                                'specialization': specializationController.text,
                            };
                            
                            // Your API call here
                            // await yourApiService.signup(userData);
                            
                          } catch (e) {
                            print('Error during signup: $e');
                          }
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
