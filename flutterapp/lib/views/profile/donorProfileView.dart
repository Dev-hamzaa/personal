import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/components/header.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _imageFile;
  String? _profileImageUrl;

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

            // Handle profile image URL
            try {
              if (donorData.containsKey('profilePic') &&
                  donorData['profilePic'] != null &&
                  donorData['profilePic'].toString().isNotEmpty) {
                final fullPath = donorData['profilePic'].toString();
                // Extract just the filename from the full path
                final fileName = fullPath.split('\\').last;
                _profileImageUrl = '${Endpoints.baseUrl}uploads/$fileName';
              } else {
                _profileImageUrl = null;
              }
            } catch (e) {
              print('Error handling image URL: $e');
              _profileImageUrl = null;
            }

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

  Future<void> _pickImage() async {
    if (!mounted) return;

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateProfile() async {
    if (!mounted) return;

    try {
      setState(() {
        isLoading = true;
      });

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Endpoints.baseUrl}api/donor/$userId'),
      );

      request.fields['name'] = nameController.text;
      request.fields['phone'] = phoneController.text;
      request.fields['bloodType'] = bloodTypeController.text;
      request.fields['organType'] = json.encode(selectedOrgans);

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _imageFile!.path,
          ),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (!mounted) return;

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        if (jsonResponse['success'] == true) {
          await getDonorDetails();
          if (!mounted) return;
          setState(() {
            isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile Updated Successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw jsonResponse['message'] ?? 'Failed to update profile';
        }
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
    _imageFile = null;
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
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (_profileImageUrl != null
                                      ? NetworkImage(
                                          _profileImageUrl!,
                                          headers: {
                                            'Accept': '*/*',
                                          },
                                        )
                                      : null) as ImageProvider?,
                              child: (_imageFile == null &&
                                      _profileImageUrl == null)
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[400],
                                    )
                                  : null,
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
                                    onPressed: _pickImage,
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
