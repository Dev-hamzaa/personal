import 'package:flutter/material.dart';
import 'package:flutterapp/components/header.dart';

class DoctorHomeView extends StatefulWidget {
  const DoctorHomeView({super.key});

  @override
  State<DoctorHomeView> createState() => _DoctorHomeViewState();
}

class _DoctorHomeViewState extends State<DoctorHomeView> {
  // Add this dummy data at class level
  final List<Map<String, dynamic>> appointments = [
    {
      'patientName': 'Ali',
      'age': '45',
      'time': '09:00 AM',
      'date': '2024-03-20',
      'reason': 'Regular Checkup',
      'status': 'pending',
    },
    {
      'patientName': 'Ahmed',
      'age': '52',
      'time': '10:00 AM',
      'date': '2024-03-20',
      'reason': 'Follow-up',
      'status': 'pending',
    },
    {
      'patientName': 'Hamza',
      'age': '35',
      'time': '11:00 AM',
      'date': '2024-03-20',
      'reason': 'Consultation',
      'status': 'pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,  // Add background color to prevent transparency
        child: Column(
          children: [
            // Add header at the top
            const Header(),
            
            // Fixed Profile Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Doctor Image
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Doctor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dr. Abuzar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Text('Cardiologist'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrollable List Section
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollNotification) {
                  // Prevent parent scroll
                  return true;
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const ClampingScrollPhysics(),  // Changed scroll physics
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(appointment['patientName']!),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Age: ${appointment['age']}'),
                                Text('Time: ${appointment['time']}'),
                                Text('Date: ${appointment['date']}'),
                                Text('Reason: ${appointment['reason']}'),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (appointment['status'] == 'pending') ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        appointments[index]['status'] = 'accepted';
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Appointment Accepted'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    child: const Text('Accept'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        appointments[index]['status'] = 'declined';
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Appointment Declined'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    child: const Text('Decline'),
                                  ),
                                ] else if (appointment['status'] == 'accepted') ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        appointments[index]['status'] = 'completed';
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Appointment Marked as Completed'),
                                          backgroundColor: Colors.blue,
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                    ),
                                    child: const Text('Mark as Completed'),
                                  ),
                                ] else if (appointment['status'] == 'completed') ...[
                                  const Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ] else if (appointment['status'] == 'declined') ...[
                                  const Text(
                                    'Declined',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DoctorLayout extends StatefulWidget {
  const DoctorLayout({super.key});

  @override
  State<DoctorLayout> createState() => _DoctorLayoutState();
}

class _DoctorLayoutState extends State<DoctorLayout> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DoctorHomeView(), // Home/Appointments view
    const Center(child: Text('Settings')), // Placeholder for Settings
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
