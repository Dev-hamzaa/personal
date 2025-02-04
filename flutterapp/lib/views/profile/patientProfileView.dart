import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutterapp/components/header.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    // TODO: Load user data from API
    // For now, using dummy data
    nameController.text = "John Smith";
    emailController.text = "john.smith@example.com";
    phoneController.text = "+1234567890";
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
                      // Profile Picture Section
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                          if (isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    // TODO: Implement image picker
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                      20.heightBox,

                      // Edit Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              isEditing = !isEditing;
                            });
                          },
                          icon: Icon(isEditing ? Icons.check : Icons.edit),
                          label: Text(isEditing ? 'Save' : 'Edit'),
                        ),
                      ),
                      20.heightBox,

                      // Form Fields
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
                      20.heightBox,

                      if (isEditing)
                        CustomButton(
                          buttonText: "Update Profile",
                          onTap: () {
                            // TODO: Implement profile update logic
                            setState(() {
                              isEditing = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile Updated Successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                        ),
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    specializationController.dispose();
    super.dispose();
  }
}

// Extension to disable/enable TextFields
extension DisableTextField on Widget {
  Widget makeDisabled(bool disabled) {
    return IgnorePointer(
      ignoring: disabled,
      child: this,
    );
  }
}
