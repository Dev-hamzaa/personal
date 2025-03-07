import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutterapp/components/header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specializationController =
      TextEditingController();
  bool isEditing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
  }

  Future<void> fetchPatientDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      print('Fetching patient details for ID: $userId');

      final response = await http.get(
        Uri.parse('${Endpoints.getPatientDetails}/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('\n=== Patient Details Response ===');
        print('Success: ${responseData['success']}');
        print('Message: ${responseData['message']}');
        print('Data: ${json.encode(responseData['data'])}');
        print('===========================\n');

        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];
          setState(() {
            nameController.text = userData['name'] ?? '';
            emailController.text = userData['email'] ?? '';
            phoneController.text = userData['phone'] ?? '';
            isLoading = false;
          });
        } else {
          throw responseData['message'] ?? 'Failed to fetch patient details';
        }
      } else {
        throw 'Failed to fetch patient details';
      }
    } catch (e) {
      print('Error fetching patient details: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateProfile() async {
    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      print('Updating profile for ID: $userId');
      print('Update data: ${json.encode({
            'name': nameController.text,
            'phone': phoneController.text,
          })}');

      final response = await http.put(
        Uri.parse('${Endpoints.getPatientDetails}/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text,
          'phone': phoneController.text,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Fetch updated details
          await fetchPatientDetails();
          setState(() {
            isEditing = false;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile Updated Successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw responseData['message'] ?? 'Failed to update profile';
        }
      } else {
        throw 'Failed to update profile';
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else
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
                            onPressed: isLoading
                                ? null
                                : () {
                                    if (isEditing) {
                                      updateProfile();
                                    } else {
                                      setState(() {
                                        isEditing = true;
                                      });
                                    }
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
                        ).makeDisabled(true),
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
                              print('\n=== Update Profile Button Clicked ===');
                              print('isLoading: $isLoading');
                              print('isEditing: $isEditing');
                              print('Name: ${nameController.text}');
                              print('Phone: ${phoneController.text}');
                              print('================================\n');

                              if (!isLoading) {
                                updateProfile();
                              } else {
                                print('Update skipped - loading state is true');
                              }
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
