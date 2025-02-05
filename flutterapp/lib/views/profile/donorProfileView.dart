import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/components/header.dart';
import 'package:velocity_x/velocity_x.dart';

class DonorProfileView extends StatefulWidget {
  const DonorProfileView({super.key});

  @override
  State<DonorProfileView> createState() => _DonorProfileViewState();
}

class _DonorProfileViewState extends State<DonorProfileView> {
  bool isEditing = false;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bloodTypeController = TextEditingController();
  final organTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Load user data from API
    // For now, using dummy data
    nameController.text = "John Smith";
    emailController.text = "john.smith@example.com";
    phoneController.text = "+1234567890";
    bloodTypeController.text = "O+";
    organTypeController.text = "Kidney";
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bloodTypeController.dispose();
    organTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage('assets/images/profile.png'),
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                      20.heightBox,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                if (isEditing) {
                                  // TODO: Save changes to backend
                                }
                                isEditing = !isEditing;
                              });
                            },
                            child: Text(isEditing ? "Save" : "Edit"),
                          ),
                        ],
                      ),
                      CustomTextField(
                        hint: "Full Name",
                        prefixIcon: Icons.person,
                        textController: nameController,
                      ).makeDisabled(!isEditing),
                      10.heightBox,
                      CustomTextField(
                        hint: "Email",
                        prefixIcon: Icons.email,
                        textController: emailController,
                      ).makeDisabled(!isEditing),
                      10.heightBox,
                      CustomTextField(
                        hint: "Phone Number",
                        prefixIcon: Icons.phone,
                        textController: phoneController,
                      ).makeDisabled(!isEditing),
                      10.heightBox,
                      if (isEditing) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: bloodTypeController.text,
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
                      ] else ...[
                        CustomTextField(
                          hint: "Blood Type",
                          prefixIcon: Icons.bloodtype,
                          textController: bloodTypeController,
                        ).makeDisabled(true),
                      ],
                      10.heightBox,
                      if (isEditing) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: organTypeController.text,
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
                              organTypeController.text = value ?? '';
                            },
                          ),
                        ),
                      ] else ...[
                        CustomTextField(
                          hint: "Organ Type",
                          prefixIcon: Icons.volunteer_activism,
                          textController: organTypeController,
                        ).makeDisabled(true),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on Widget {
  Widget makeDisabled(bool disabled) {
    return IgnorePointer(
      ignoring: disabled,
      child: Opacity(
        opacity: disabled ? 0.6 : 1.0,
        child: this,
      ),
    );
  }
} 