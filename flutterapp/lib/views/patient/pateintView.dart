import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutterapp/views/patient/bookAppointment.dart';
import 'package:flutterapp/components/header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientView extends StatefulWidget {
  const PatientView({super.key});

  @override
  State<PatientView> createState() => _PatientViewState();
}

class _PatientViewState extends State<PatientView> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  bool isLoadingUser = true;
  String selectedSpecialty = 'All';
  Map<String, dynamic>? userDetails;

    final TextEditingController nameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    fetchDoctors();
  }

  Future<void> fetchUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      print('Fetching user details for ID: $userId');

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
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            userDetails = responseData['data'];
            isLoadingUser = false;
          });
        }
      } else {
        throw 'Failed to fetch user details';
      }
    } catch (e) {
      print('Error fetching user details: $e');
      if (!mounted) return;
      setState(() {
        isLoadingUser = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchDoctors() async {
    try {
      final response = await http.get(
        Uri.parse(Endpoints.getAllDoctors),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          if (!mounted) return;
          setState(() {
            doctors = List<Map<String, dynamic>>.from(responseData['data']);
            isLoading = false;
          });
        }
      } else {
        throw 'Failed to fetch doctors';
      }
    } catch (e) {
      print('Error fetching doctors: $e');
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

  // List<Map<String, dynamic>> getFilteredDoctors() {
  //   if (selectedSpecialty == 'All') {
  //     return doctors;
  //   }
  //   return doctors
  //       .where((doctor) =>
  //           doctor['name']?.toLowerCase() ==
  //           selectedSpecialty.toLowerCase())
  //       .toList();
  // }
List<Map<String, dynamic>> getFilteredDoctors() {
  return doctors.where((doctor) {
    // Check if the doctor's name contains the search query (case-insensitive)
    final nameMatch = doctor['name']
        ?.toLowerCase()
        .contains(nameController.text.toLowerCase()) ?? false;
    
    // Check if the doctor's specialization matches the selected category
    // final specialtyMatch = selectedSpecialty == 'All' ||
    //     doctor['specialization']?.toLowerCase() == selectedSpecialty.toLowerCase();
    
    return nameMatch;
  }).toList();
}

  @override
  Widget build(BuildContext context) {
    final filteredDoctors = getFilteredDoctors();

    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "Find Doctors".text.bold.xl2.make().p16(),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: nameController,
                       onChanged: (value) {
      setState(() {}); // Just refresh the UI, no need to set controller.text manually
    },
                      decoration: InputDecoration(
                        hintText: "Search doctors...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  10.heightBox,

                  // Specializations horizontal list
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        'All',
                        'Cardiologist',
                        'Dentist',
                        'Pediatrician',
                        'Neurologist',
                      ].map((specialty) {
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          child: FilterChip(
                            label: specialty.text.make(),
                            selected: selectedSpecialty == specialty,
                            onSelected: (bool selected) {
                              setState(() {
                                selectedSpecialty = specialty;
                              });
                            },
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            selectedColor: Colors.blue.withOpacity(0.3),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Doctors List
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredDoctors.length,
                            itemBuilder: (context, index) {
                              final doctor = filteredDoctors[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundColor: Colors.grey[300],
                                            child: const Icon(
                                              Icons.person,
                                              size: 30,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          20.widthBox,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Dr. ${doctor['name'] ?? 'Unknown'}",
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  doctor['specialization'] ??
                                                      'Specialization not specified',
                                                  style: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      10.heightBox,
                                      CustomButton(
                                        buttonText: "Book Appointment",
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AppointmentBookingView(
                                                doctorId: doctor['_id'],
                                                doctorName: doctor['name'],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
