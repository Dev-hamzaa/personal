import 'package:flutter/material.dart';
import 'package:flutterapp/components/header.dart';

class DoctorView extends StatelessWidget {
  const DoctorView({super.key});

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
                          'Dr. John Doe',
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
                  itemCount: 20,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text('Appointment ${index + 1}'),
                        subtitle: const Text('Patient details here'),
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
    const DoctorView(), // Home/Appointments view
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
