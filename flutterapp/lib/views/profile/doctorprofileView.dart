import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/components/header.dart';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String selectedSpecialization = '';
  bool isEditing = false;
  bool isLoading = true;
  File? _imageFile;
  String? _profileImageUrl;

  // Add list of specializations
  final List<String> specializations = [
    'Cardiologist',
    'Dentist',
    'Pediatrician',
    'Neurologist',
  ];

  // Schedule data structure
  List<Map<String, dynamic>> schedules = [];
  final List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error picking image'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Endpoints.getDoctorDetails}/$userId/upload-image'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'profilePic',
          _imageFile!.path,
        ),
      );

      print('Uploading image to: ${request.url}');
      print('File path: ${_imageFile!.path}');

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response data: $responseData');

      if (response.statusCode == 200) {
        try {
          var jsonResponse = json.decode(responseData);
          if (jsonResponse['success'] == true) {
            setState(() {
              _profileImageUrl = jsonResponse['data']['imageUrl'];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw jsonResponse['message'] ?? 'Failed to upload image';
          }
        } catch (e) {
          print('Error parsing response: $e');
          throw 'Invalid response from server';
        }
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchDoctorDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      final response = await http.get(
        Uri.parse('${Endpoints.baseUrl}api/doctor/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Response from server: $responseData'); // Debug log

        if (responseData['success'] == true && responseData['data'] != null) {
          final doctorData = responseData['data'];
          setState(() {
            nameController.text = doctorData['name'] ?? '';
            emailController.text = doctorData['email'] ?? '';
            phoneController.text = doctorData['phone'] ?? '';
            selectedSpecialization = doctorData['specialization'] ?? '';

            // Safely handle imageUrl - it might not exist for new users
            try {
              if (doctorData.containsKey('profilePic') &&
                  doctorData['profilePic'] != null &&
                  doctorData['profilePic'].toString().isNotEmpty) {
                final fullPath = doctorData['profilePic'].toString();
                // Extract just the filename from the full path
                final fileName = fullPath.split('\\').last;
                _profileImageUrl = '${Endpoints.baseUrl}uploads/$fileName';
                print('Image URL constructed: $_profileImageUrl'); // Debug log
              } else {
                _profileImageUrl = null;
                print('No profile image URL found in response'); // Debug log
              }
            } catch (e) {
              print('Error handling image URL: $e');
              _profileImageUrl = null;
            }

            // Handle schedules if they exist in the response
            if (doctorData['weeklySchedule'] != null &&
                doctorData['weeklySchedule'] is List &&
                doctorData['weeklySchedule'].isNotEmpty) {
              schedules = List<Map<String, dynamic>>.from(
                  doctorData['weeklySchedule'].map((schedule) => {
                        'day': schedule['day'],
                        'start': schedule['start'],
                        'end': schedule['end'],
                      }));
            } else {
              // Add default schedule if none exists
              schedules = [
                {
                  'day': 'Monday',
                  'start': '09:00',
                  'end': '17:00',
                }
              ];
            }

            isLoading = false;
          });
        }
      } else {
        throw 'Failed to fetch doctor details';
      }
    } catch (e) {
      print('Error fetching doctor details: $e');
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

  Future<void> updateDoctorProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      // Format the weekly schedule
      List<Map<String, dynamic>> formattedSchedules = schedules.map((schedule) {
        // Ensure start time is in AM/PM format
        String startTime = schedule['start'];
        if (!startTime.contains('AM') && !startTime.contains('PM')) {
          // Convert 24-hour time to AM/PM format
          int hour = int.parse(startTime.split(':')[0]);
          int minute = int.parse(startTime.split(':')[1]);
          String period = hour >= 12 ? 'PM' : 'AM';
          if (hour > 12) hour -= 12;
          if (hour == 0) hour = 12;
          startTime =
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }

        // Ensure end time is in AM/PM format
        String endTime = schedule['end'];
        if (!endTime.contains('AM') && !endTime.contains('PM')) {
          // Convert 24-hour time to AM/PM format
          int hour = int.parse(endTime.split(':')[0]);
          int minute = int.parse(endTime.split(':')[1]);
          String period = hour >= 12 ? 'PM' : 'AM';
          if (hour > 12) hour -= 12;
          if (hour == 0) hour = 12;
          endTime =
              '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }

        return {
          'day': schedule['day'],
          'start': startTime,
          'end': endTime,
        };
      }).toList();

      // Create multipart request
      var request = http.MultipartRequest(
        'PUT',
        Uri.parse('${Endpoints.getDoctorDetails}/$userId'),
      );

      // Add text fields
      request.fields['name'] = nameController.text;
      request.fields['email'] = emailController.text;
      request.fields['phoneNumber'] = phoneController.text;
      request.fields['specialization'] = selectedSpecialization;
      request.fields['weeklySchedule'] = json.encode(formattedSchedules);

      // Add image file if selected
      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePic',
            _imageFile!.path,
          ),
        );
      }

      // Log complete request details
      print('\n=== Request Details ===');
      print('URL: ${request.url}');
      print('\nFields:');
      request.fields.forEach((key, value) {
        print('$key: $value');
      });
      print('\nFiles:');
      for (var file in request.files) {
        print('Field: ${file.field}');
        print('Filename: ${file.filename}');
        print('Content-Type: ${file.contentType}');
        print('Length: ${file.length}');
      }
      print('\nHeaders:');
      request.headers.forEach((key, value) {
        print('$key: $value');
      });
      print('====================\n');

      // Send the request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('Response status: ${response.statusCode}');
      print('Response data: $responseData');

      if (response.statusCode == 200) {
        try {
          var jsonResponse = json.decode(responseData);
          if (jsonResponse['success'] == true) {
            setState(() {
              isEditing = false;
              if (jsonResponse['data'] != null &&
                  jsonResponse['data']['imageUrl'] != null) {
                _profileImageUrl = jsonResponse['data']['imageUrl'];
              }
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
        } catch (e) {
          print('Error parsing response: $e');
          throw 'Invalid response from server';
        }
      } else {
        throw 'Server error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addNewSchedule() {
    setState(() {
      schedules.add({
        'day': weekDays[0],
        'start': '09:00',
        'end': '17:00',
      });
    });
  }

  Future<void> _selectTime(
      BuildContext context, int index, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final String formattedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';

        if (isStartTime) {
          schedules[index]['start'] = formattedTime;
        } else {
          schedules[index]['end'] = formattedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Header(),
                    const SizedBox(height: 20),

                    // Profile Picture and Edit Button
                    Center(
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.grey[300],
                                backgroundImage: _profileImageUrl != null
                                    ? NetworkImage(
                                        _profileImageUrl!,
                                        headers: {
                                          'Accept': '*/*',
                                        },
                                      )
                                    : _imageFile != null
                                        ? FileImage(_imageFile!)
                                            as ImageProvider
                                        : null,
                                child: (_profileImageUrl == null &&
                                        _imageFile == null)
                                    ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: Colors.grey,
                                      )
                                    : null,
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
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      onPressed: _pickImage,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                isEditing = !isEditing;
                              });
                            },
                            icon: Icon(isEditing ? Icons.check : Icons.edit),
                            label: Text(isEditing ? 'Save' : 'Edit Profile'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Basic Info Fields
                    CustomTextField(
                      hint: "Full Name",
                      prefixIcon: Icons.person,
                      textController: nameController,
                      readOnly: !isEditing,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      hint: "Email",
                      prefixIcon: Icons.email,
                      textController: emailController,
                      readOnly: !isEditing,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      hint: "Phone Number",
                      prefixIcon: Icons.phone,
                      textController: phoneController,
                      readOnly: !isEditing,
                    ),
                    const SizedBox(height: 16),

                    // Replace CustomTextField with DropdownButtonFormField for specialization
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: specializations.contains(selectedSpecialization)
                            ? selectedSpecialization
                            : null,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.work),
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        hint: const Text('Select Specialization'),
                        items: specializations.map((String specialty) {
                          return DropdownMenuItem<String>(
                            value: specialty,
                            child: Text(specialty),
                          );
                        }).toList(),
                        onChanged: isEditing
                            ? (String? value) {
                                if (value != null) {
                                  setState(() {
                                    selectedSpecialization = value;
                                  });
                                }
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Schedule List
                    Container(
                      width: double.infinity,
                      child: _buildScheduleList(),
                    ),

                    const SizedBox(height: 20),

                    // Update Profile Button
                    if (isEditing)
                      CustomButton(
                        buttonText: "Update Profile",
                        onTap: () async {
                          await updateDoctorProfile();
                        },
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekly Schedule Header with Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Weekly Schedule",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isEditing)
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                onPressed: _addNewSchedule,
                tooltip: 'Add Schedule',
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Schedule Items
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: schedules.length,
          itemBuilder: (context, idx) {
            final schedule = schedules[idx];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Day Dropdown
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: schedule['day'],
                            decoration: const InputDecoration(
                              labelText: 'Select Day',
                              border: OutlineInputBorder(),
                            ),
                            items: weekDays.map((String day) {
                              return DropdownMenuItem<String>(
                                value: day,
                                child: Text(day),
                              );
                            }).toList(),
                            onChanged: isEditing
                                ? (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        schedule['day'] = newValue;
                                      });
                                    }
                                  }
                                : null,
                          ),
                        ),
                        if (isEditing && schedules.length > 1)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => setState(() {
                              schedules.removeAt(idx);
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Time Selection Row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            hint: "Start Time",
                            prefixIcon: Icons.access_time,
                            textController: TextEditingController(
                              text: schedule['start'],
                            ),
                            readOnly: true,
                            onTap: isEditing
                                ? () => _selectTime(context, idx, true)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomTextField(
                            hint: "End Time",
                            prefixIcon: Icons.access_time,
                            textController: TextEditingController(
                              text: schedule['end'],
                            ),
                            readOnly: true,
                            onTap: isEditing
                                ? () => _selectTime(context, idx, false)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
