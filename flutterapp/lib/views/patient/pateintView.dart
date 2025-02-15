import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutterapp/views/patient/bookAppointment.dart';
import 'package:flutterapp/components/header.dart';

class PatientView extends StatelessWidget {
  const PatientView({super.key});

  // Add doctor list
  final List<Map<String, dynamic>> doctors = const [
    {
      'name': 'Dr. Ali Usman',
      'specialization': 'Cardiologist',
      'rating': '4.5',
      'reviews': '120',
      'availability': '9:00 AM - 5:00 PM',
    },
    {
      'name': 'Dr. Bilal',
      'specialization': 'Neurologist',
      'rating': '4.8',
      'reviews': '95',
      'availability': '10:00 AM - 6:00 PM',
    },
    {
      'name': 'Dr. Ali',
      'specialization': 'Orthopedic',
      'rating': '4.6',
      'reviews': '150',
      'availability': '8:00 AM - 4:00 PM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Add header at the top
            const Header(),
            
            // Your existing PatientView content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  "Find Doctors".text.bold.xl2.make().p16(),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
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
                          child: Chip(
                            label: specialty.text.make(),
                            backgroundColor: Colors.blue.withOpacity(0.1),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Doctors List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: doctors.length, // Changed to doctors.length
                      itemBuilder: (context, index) {
                        final doctor = doctors[index]; // Get doctor data
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doctor['name']!,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            doctor['specialization']!,
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.yellow,
                                                size: 16,
                                              ),
                                              Text(" ${doctor['rating']}"),
                                              Text(
                                                " (${doctor['reviews']} reviews)",
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                10.heightBox,
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    10.widthBox,
                                    "Available Today: ".text.gray500.make(),
                                    Text(doctor['availability']!),
                                  ],
                                ),
                                10.heightBox,
                                CustomButton(
                                  buttonText: "Book Appointment",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AppointmentBookingView(),
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
