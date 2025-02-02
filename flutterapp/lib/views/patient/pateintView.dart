import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutterapp/views/patient/bookAppointment.dart';
import 'package:flutterapp/components/header.dart';

class PatientView extends StatelessWidget {
  const PatientView({super.key});

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
                      itemCount: 10, // Replace with actual doctor count from API
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Doctor info row
                                Row(
                                  children: [
                                    // Doctor image
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
                                    // Doctor details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          "Dr. John Doe ${index + 1}".text.bold.xl.make(),
                                          "Cardiologist".text.gray500.make(),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, 
                                                color: Colors.yellow,
                                                size: 16,
                                              ),
                                              " 4.5".text.make(),
                                              " (120 reviews)".text.gray500.make(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                10.heightBox,
                                // Available time slots
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, 
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    10.widthBox,
                                    "Available Today: ".text.gray500.make(),
                                    "9:00 AM - 5:00 PM".text.make(),
                                  ],
                                ),
                                10.heightBox,
                                // Book appointment button
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
