// ignore_for_file: avoid_print

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
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    fetchDoctors();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUserDetails() async {
    if (!mounted) return;

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

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            userDetails = Map<String, dynamic>.from(responseData['data']);
            isLoadingUser = false;
          });
        } else {
          throw 'Invalid response format';
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
    if (!mounted) return;

    try {
      final response = await http.get(
        Uri.parse(Endpoints.getAllDoctors),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            doctors = List<Map<String, dynamic>>.from(
              (responseData['data'] as List).map((item) =>
                  Map<String, dynamic>.from(item as Map<String, dynamic>)),
            );
            isLoading = false;
          });
        } else {
          throw 'Invalid response format';
        }
      } else {
        throw 'Failed to fetch doctors';
      }
    } catch (e) {
      print('Error fetching doctors: $e');
      if (!mounted) return;
      setState(() {
        doctors = [];
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

  List<Map<String, dynamic>> getFilteredDoctors() {
    if (doctors.isEmpty) return [];

    if (selectedSpecialty == 'All') {
      return doctors;
    }

    return doctors.where((doctor) {
      final specialization =
          doctor['specialization']?.toString().toLowerCase() ?? '';
      return specialization == selectedSpecialty.toLowerCase();
    }).toList();
  }

  Future<void> updateDoctorRating(String doctorId, double rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      final response = await http.patch(
        Uri.parse(
            '${Endpoints.baseUrl}api/doctor/patch/$doctorId?userId=$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'rating': rating,
        }),
      );

      print("Response is----------------------->${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Refresh the doctors list to show updated rating
          await fetchDoctors();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Rating updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw responseData['message'] ?? 'Failed to update rating';
        }
      } else {
        throw 'Failed to update rating';
      }
    } catch (e) {
      print('Error updating rating: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> showRatingDialog(String doctorId) async {
    double selectedRating = 0;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Rate Doctor'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating.floor()
                          ? Icons.star
                          : Icons.star_border,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1.0;
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedRating == 0
                      ? null
                      : () {
                          Navigator.pop(context);
                          updateDoctorRating(doctorId, selectedRating);
                        },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
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
            if (!isLoadingUser && userDetails != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: userDetails?['profilePic'] != null &&
                              userDetails!['profilePic'].toString().isNotEmpty
                          ? NetworkImage(
                              '${Endpoints.baseUrl}uploads/${userDetails!['profilePic'].toString().split('\\').last}',
                              headers: {
                                'Accept': '*/*',
                              },
                            )
                          : null,
                      child: userDetails?['profilePic'] == null ||
                              userDetails!['profilePic'].toString().isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    20.widthBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${userDetails?['name'] ?? 'Patient'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          if (userDetails?['email'] != null)
                            Text(
                              userDetails!['email'],
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  "Find Doctors".text.bold.xl2.make().p16(),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: searchController,
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
                            label: Text(specialty),
                            selected: selectedSpecialty == specialty,
                            onSelected: (bool selected) {
                              if (mounted) {
                                setState(() {
                                  selectedSpecialty = specialty;
                                });
                              }
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
                        : filteredDoctors.isEmpty
                            ? const Center(
                                child: Text('No doctors found'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredDoctors.length,
                                itemBuilder: (context, index) {
                                  final doctor = filteredDoctors[index];
                                  final double rating =
                                      (doctor['rating'] as num?)?.toDouble() ??
                                          0.0;
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
                                                backgroundColor:
                                                    Colors.grey[300],
                                                backgroundImage:
                                                    doctor['profilePic'] !=
                                                                null &&
                                                            doctor['profilePic']
                                                                .toString()
                                                                .isNotEmpty
                                                        ? NetworkImage(
                                                            '${Endpoints.baseUrl}uploads/${doctor['profilePic'].toString().split('\\').last}',
                                                            headers: {
                                                              'Accept': '*/*',
                                                            },
                                                          )
                                                        : null,
                                                child: doctor['profilePic'] ==
                                                            null ||
                                                        doctor['profilePic']
                                                            .toString()
                                                            .isEmpty
                                                    ? const Icon(
                                                        Icons.person,
                                                        size: 30,
                                                        color: Colors.grey,
                                                      )
                                                    : null,
                                              ),
                                              20.widthBox,
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          "Dr. ${doctor['name']?.toString() ?? 'Unknown'}",
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        if (rating > 0)
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons.star,
                                                                size: 20,
                                                                color: Colors
                                                                    .amber,
                                                              ),
                                                              const SizedBox(
                                                                  width: 4),
                                                              Text(
                                                                rating
                                                                    .toStringAsFixed(
                                                                        1),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                      ],
                                                    ),
                                                    Text(
                                                      doctor['specialization']
                                                              ?.toString() ??
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: CustomButton(
                                                  buttonText:
                                                      "Book Appointment",
                                                  onTap: () {
                                                    if (mounted) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              AppointmentBookingView(
                                                            doctorId: doctor[
                                                                        '_id']
                                                                    ?.toString() ??
                                                                '',
                                                            doctorName: doctor[
                                                                        'name']
                                                                    ?.toString() ??
                                                                'Unknown',
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton.icon(
                                                onPressed: () =>
                                                    showRatingDialog(
                                                        doctor['_id']),
                                                icon: const Icon(
                                                    Icons.star_border),
                                                label: const Text('Rate'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.amber,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 16,
                                                    vertical: 12,
                                                  ),
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
