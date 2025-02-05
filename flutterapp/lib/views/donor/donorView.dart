import 'package:flutter/material.dart';
import 'package:flutterapp/components/header.dart';

class DonorView extends StatefulWidget {
  const DonorView({super.key});

  @override
  State<DonorView> createState() => _DonorViewState();
}

class _DonorViewState extends State<DonorView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Dummy data - Replace with actual API data
  final List<Map<String, String>> organRequests = [
    {
      'name': 'Sarah Johnson',
      'age': '45',
      'organ': 'Kidney',
      'urgency': 'High',
      'location': 'New York',
      'contact': '+1234567890',
    },
    {
      'name': 'Mike Smith',
      'age': '52',
      'organ': 'Liver',
      'urgency': 'Medium',
      'location': 'Boston',
      'contact': '+1234567891',
    },
  ];

  final List<Map<String, String>> bloodRequests = [
    {
      'name': 'John Doe',
      'age': '35',
      'bloodType': 'O+',
      'urgency': 'High',
      'location': 'Chicago',
      'contact': '+1234567892',
    },
    {
      'name': 'Emma Wilson',
      'age': '28',
      'bloodType': 'A-',
      'urgency': 'Medium',
      'location': 'Miami',
      'contact': '+1234567893',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Organ Requests'),
                Tab(text: 'Blood Requests'),
              ],
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Organ Requests Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: organRequests.length,
                    itemBuilder: (context, index) {
                      final request = organRequests[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            request['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('Age: ${request['age']}'),
                              Text('Organ Needed: ${request['organ']}'),
                              Text('Urgency: ${request['urgency']}'),
                              Text('Location: ${request['location']}'),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Implement accept functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request Accepted'),
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
                                      // Implement decline functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request Declined'),
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Blood Requests Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: bloodRequests.length,
                    itemBuilder: (context, index) {
                      final request = bloodRequests[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            request['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text('Age: ${request['age']}'),
                              Text('Blood Type: ${request['bloodType']}'),
                              Text('Urgency: ${request['urgency']}'),
                              Text('Location: ${request['location']}'),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Implement accept functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request Accepted'),
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
                                      // Implement decline functionality
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Request Declined'),
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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