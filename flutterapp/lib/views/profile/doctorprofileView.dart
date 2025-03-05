import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/components/header.dart';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DoctorProfileView extends StatefulWidget {
  const DoctorProfileView({super.key});

  @override
  State<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends State<DoctorProfileView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  bool isEditing = false;
  bool isLoading = true;

  // Schedule data structure
  List<Map<String, dynamic>>  schedules = [];
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

  Future<void> fetchDoctorDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      final response = await http.get(
        Uri.parse('${Endpoints.getDoctorDetails}/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Fetching doctor details for userId: $userId');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final doctorData = responseData['data'];
          setState(() {
            nameController.text = doctorData['name'] ?? '';
            emailController.text = doctorData['email'] ?? '';
            phoneController.text = doctorData['phone'] ?? '';
            specializationController.text = doctorData['specialization'] ?? '';
            
            // Handle schedules if they exist in the response
            if (doctorData['weeklySchedule'] != null && 
                doctorData['weeklySchedule'] is List && 
                doctorData['weeklySchedule'].isNotEmpty) {
              
              schedules = List<Map<String, dynamic>>.from(
                doctorData['weeklySchedule'].map((schedule) => {
                  'day': schedule['day'],
                  'start': schedule['start'],
                  'end': schedule['end'],
                })
              );
              
            } else {
              // Add default schedule if none exists
              schedules = [{
                'day': 'Monday',
                'start': '09:00',
                'end': '17:00',
              }];
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
          startTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
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
          endTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }

        return {
          'day': schedule['day'],
          'start': startTime,
          'end': endTime,
        };
      }).toList();

      final Map<String, dynamic> updateData = {
        'name': nameController.text,
        'email': emailController.text,
        'phoneNumber': phoneController.text,
        'specialization': specializationController.text,
        'weeklySchedule': formattedSchedules,
      };

      print('update Request Body is: ${json.encode(updateData)}');

      final response = await http.put(
        Uri.parse('${Endpoints.getDoctorDetails}/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
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
        throw 'Failed to update profile';
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

  // Helper function to convert 24-hour time to 12-hour format with AM/PM
  String convertTo12Hour(String time24) {
    try {
      // Remove any extra spaces
      time24 = time24.trim();
      
      // Parse the time
      List<String> parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      // Convert to 12-hour format
      String period = 'AM';
      if (hour >= 12) {
        period = 'PM';
        if (hour > 12) {
          hour -= 12;
        }
      } else if (hour == 0) {
        hour = 12;
      }

      // Return formatted string
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      print('Error converting time: $e');
      return time24; // Return original if conversion fails
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

  void _removeSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }

  Future<void> _selectTime(BuildContext context, int index, bool isStartTime) async {
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

        print('Selected time: $formattedTime');
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
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.grey,
                          ),
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

                  CustomTextField(
                    hint: "Specialization",
                    prefixIcon: Icons.work,
                    textController: specializationController,
                    readOnly: !isEditing,
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
    specializationController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}
