import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutterapp/components/header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _imageFile;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      fetchPatientDetails();
    }
  }

  Future<void> fetchPatientDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      final response = await http.get(
        Uri.parse('${Endpoints.getPatientDetails}/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];
          setState(() {
            nameController.text = userData['name'] ?? '';
            emailController.text = userData['email'] ?? '';
            phoneController.text = userData['phone'] ?? '';

            // Handle profile image URL
            try {
              if (userData.containsKey('profilePic') &&
                  userData['profilePic'] != null &&
                  userData['profilePic'].toString().isNotEmpty) {
                final fullPath = userData['profilePic'].toString();
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

            isLoading = false;
          });
        } else {
          throw responseData['message'] ?? 'Failed to fetch patient details';
        }
      } else {
        throw 'Failed to fetch patient details';
      }
    } catch (e) {
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
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    specializationController.dispose();
    _imageFile = null;
    super.dispose();
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
        Uri.parse('${Endpoints.getPatientDetails}/$userId'),
      );

      request.fields['name'] = nameController.text;
      request.fields['phone'] = phoneController.text;

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
          await fetchPatientDetails();
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
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
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
                              if (!isLoading) {
                                updateProfile();
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
