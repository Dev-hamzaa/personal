import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/components/header.dart';

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

  // Schedule data structure
  List<Map<String, dynamic>> schedules = [];
  final List<String> weekDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  
  @override
  void initState() {
    super.initState();
    print("DoctorProfileView initialized");
    // Dummy data
    nameController.text = "Dr. John Doe";
    emailController.text = "john.doe@example.com";
    phoneController.text = "+1234567890";
    specializationController.text = "Cardiologist";
    
    // Add initial schedule
    schedules.add({
      'day': 'Monday',
      'start': '09:00 AM',
      'end': '05:00 PM',
    });
  }

  void _addNewSchedule() {
    setState(() {
      schedules.add({
        'day': weekDays[0],
        'start': '09:00 AM',
        'end': '05:00 PM',
      });
    });
  }

  void _removeSchedule(int index) {
    setState(() {
      schedules.removeAt(index);
    });
  }

  Future<void> _selectTime(BuildContext context, int index, bool isStartTime) async {
    final TimeOfDay initialTime = TimeOfDay.now();

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hourOfPeriod;
        final minute = picked.minute;
        final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
        final formattedTime = 
            '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        
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
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      hint: "Email",
                      prefixIcon: Icons.email,
                      textController: emailController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      hint: "Phone Number",
                      prefixIcon: Icons.phone,
                      textController: phoneController,
                    ),
                    const SizedBox(height: 16),

                    CustomTextField(
                      hint: "Specialization",
                      prefixIcon: Icons.work,
                      textController: specializationController,
                    ),
                    const SizedBox(height: 24),

                    // Availability Section
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
                        if (isEditing && schedules.length < 7)
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.blue),
                            onPressed: _addNewSchedule,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Schedule List
                    ...schedules.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Map<String, dynamic> schedule = entry.value;
                      
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: schedule['day'],
                                  items: weekDays
                                      .where((day) => !schedules
                                          .where((s) => s['day'] == day && s != schedule)
                                          .isNotEmpty)
                                      .map((String day) {
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
                                  decoration: const InputDecoration(
                                    labelText: 'Day',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              if (isEditing && schedules.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeSchedule(idx),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  hint: "Start Time",
                                  prefixIcon: Icons.access_time,
                                  textController: TextEditingController(text: schedule['start']),
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
                                  textController: TextEditingController(text: schedule['end']),
                                  readOnly: true,
                                  onTap: isEditing 
                                      ? () => _selectTime(context, idx, false)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),

                    if (isEditing)
                      CustomButton(
                        buttonText: "Update Profile",
                        onTap: () {
                          setState(() {
                            isEditing = false;
                          });
                          // Here you would save the schedules
                          print(schedules);  // For debugging
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
    startTimeController.dispose();
    endTimeController.dispose();
    super.dispose();
  }
}
