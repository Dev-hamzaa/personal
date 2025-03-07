import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/components/header.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonorProfileView extends StatefulWidget {
  const DonorProfileView({super.key});

  @override
  State<DonorProfileView> createState() => _DonorProfileViewState();
}

class _DonorProfileViewState extends State<DonorProfileView> {
  bool isEditing = false;
  bool isLoading = true;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final bloodTypeController = TextEditingController();
  List<String> selectedOrgans = [];

  @override
  void initState() {
    super.initState();
    getDonorDetails();
  }

  Future<void> getDonorDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      final response = await http.get(
        Uri.parse('${Endpoints.baseUrl}api/donor/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          final donorData = responseData['data'];
          setState(() {
            nameController.text = donorData['name'] ?? '';
            emailController.text = donorData['email'] ?? '';
            phoneController.text = donorData['phone'] ?? '';
            bloodTypeController.text = donorData['bloodType'] ?? '';

            // Handle organType as array
            if (donorData['organType'] != null) {
              if (donorData['organType'] is List) {
                selectedOrgans = List<String>.from(donorData['organType']);
              } else if (donorData['organType'] is String) {
                selectedOrgans = [donorData['organType']];
              }
            }

            isLoading = false;
          });
        } else {
          throw responseData['message'] ?? 'Failed to fetch donor details';
        }
      } else {
        throw 'Failed to fetch donor details';
      }
    } catch (e) {
      print('Error fetching donor details: $e');
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
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
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      final response = await http.put(
        Uri.parse('${Endpoints.baseUrl}api/donor/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': nameController.text,
          'email': emailController.text,
          'phone': phoneController.text,
          'bloodType': bloodTypeController.text,
          'organType': selectedOrgans,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            isEditing = false;
          });
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getSelectedOrgansText() {
    return selectedOrgans.isEmpty ? '' : selectedOrgans.join(', ');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    bloodTypeController.dispose();
    super.dispose();
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
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey[400],
                              ),
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
                                if (isEditing) {
                                  updateProfile();
                                } else {
                                  setState(() {
                                    isEditing = true;
                                  });
                                }
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
                        ).makeDisabled(true),
                        10.heightBox,
                        CustomTextField(
                          hint: "Phone Number",
                          prefixIcon: Icons.phone,
                          textController: phoneController,
                        ).makeDisabled(!isEditing),
                        10.heightBox,
                        if (isEditing) ...[
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButtonFormField<String>(
                                isExpanded: true,
                                value: bloodTypeController.text.isNotEmpty
                                    ? bloodTypeController.text
                                    : null,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: Icon(Icons.bloodtype),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 8),
                                ),
                                hint: const Text('Select Blood Type'),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'A+', child: Text('A+')),
                                  DropdownMenuItem(
                                      value: 'A-', child: Text('A-')),
                                  DropdownMenuItem(
                                      value: 'B+', child: Text('B+')),
                                  DropdownMenuItem(
                                      value: 'B-', child: Text('B-')),
                                  DropdownMenuItem(
                                      value: 'AB+', child: Text('AB+')),
                                  DropdownMenuItem(
                                      value: 'AB-', child: Text('AB-')),
                                  DropdownMenuItem(
                                      value: 'O+', child: Text('O+')),
                                  DropdownMenuItem(
                                      value: 'O-', child: Text('O-')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    bloodTypeController.text = value ?? '';
                                  });
                                },
                              ),
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
                          SizedBox(
                            width: double.infinity,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        Icon(Icons.volunteer_activism,
                                            color: Colors.grey),
                                        SizedBox(width: 8),
                                        Text('Select Organs for Donation',
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      'Kidney',
                                      'Liver',
                                      'Heart',
                                      'Lungs',
                                      'Pancreas',
                                      'Small Bowel'
                                    ].map((String organ) {
                                      final isSelected =
                                          selectedOrgans.contains(organ);
                                      return FilterChip(
                                        label: Text(organ),
                                        selected: isSelected,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            if (selected) {
                                              selectedOrgans.add(organ);
                                            } else {
                                              selectedOrgans.remove(organ);
                                            }
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          CustomTextField(
                            hint: "Organ Types",
                            prefixIcon: Icons.volunteer_activism,
                            textController: TextEditingController(
                                text: getSelectedOrgansText()),
                          ).makeDisabled(true),
                        ],
                        20.heightBox,
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isEditing
                                ? updateProfile
                                : () {
                                    setState(() {
                                      isEditing = true;
                                    });
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              isEditing ? 'Save Profile' : 'Update Profile',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
