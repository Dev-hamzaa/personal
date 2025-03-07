import 'package:flutter/material.dart';
import 'package:flutterapp/components/header.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DonorView extends StatefulWidget {
  const DonorView({super.key});

  @override
  State<DonorView> createState() => _DonorViewState();
}

class _DonorViewState extends State<DonorView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      fetchDonorRequests(); // Fetch requests when tab changes
    });
    fetchDonorRequests();
  }

  Future<void> fetchDonorRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      final currentIndex = _tabController.index;
      final isBloodRequest = currentIndex == 1;

      final response = await http.get(
        Uri.parse(
            '${Endpoints.baseUrl}api/request/?donor=$userId&status=pending${isBloodRequest ? '&blood=true' : ''}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            requests = responseData['data'];
            isLoading = false;
          });
        } else {
          throw responseData['message'] ?? 'Failed to fetch requests';
        }
      } else {
        throw 'Failed to fetch requests';
      }
    } catch (e) {
      print('Error fetching requests: $e');
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

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      print('Updating request $requestId to status: $status');

      final response = await http.patch(
        Uri.parse('${Endpoints.baseUrl}api/request/$requestId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': status,
          'isAccepted': status == 'accepted' ? true : false,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            // Remove the request from the local list if rejected
            if (status == 'rejected') {
              requests.removeWhere((request) => request['_id'] == requestId);
            }
          });

          // Refresh the requests list from API
          await fetchDonorRequests();

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Request ${status == 'accepted' ? 'accepted' : 'rejected'} successfully'),
              backgroundColor: status == 'accepted' ? Colors.green : Colors.red,
            ),
          );
        } else {
          throw responseData['message'] ?? 'Failed to update request';
        }
      } else {
        throw 'Failed to update request';
      }
    } catch (e) {
      print('Error updating request: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<dynamic> getOrganRequests() {
    return requests
        .where((request) => request['requestedOrgan'] != null)
        .toList();
  }

  List<dynamic> getBloodRequests() {
    return requests.where((request) => request['bloodType'] != null).toList();
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
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey, width: 0.5),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.medical_services),
                        SizedBox(width: 8),
                        Text('Organ Requests'),
                      ],
                    ),
                  ),
                  Tab(
                    height: 48,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bloodtype),
                        SizedBox(width: 8),
                        Text('Blood Requests'),
                      ],
                    ),
                  ),
                ],
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        // Organ Requests Tab
                        ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: getOrganRequests().length,
                          itemBuilder: (context, index) {
                            final request = getOrganRequests()[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  request['patientId']?['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text(
                                        'Organ Needed: ${request['requestedOrgan']}'),
                                    Text('Status: ${request['status']}'),
                                    Text(
                                        'Requested on: ${DateTime.parse(request['createdAt']).toLocal().toString().split(' ')[0]}'),
                                    const SizedBox(height: 10),
                                    if (request['status'] == 'pending')
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                updateRequestStatus(
                                                    request['_id'], 'accepted'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                            ),
                                            child: const Text('Accept'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () =>
                                                updateRequestStatus(
                                                    request['_id'], 'rejected'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
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
                          itemCount: getBloodRequests().length,
                          itemBuilder: (context, index) {
                            final request = getBloodRequests()[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  request['patientId']?['name'] ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8),
                                    Text('Blood Type: ${request['bloodType']}'),
                                    Text('Status: ${request['status']}'),
                                    Text(
                                        'Requested on: ${DateTime.parse(request['createdAt']).toLocal().toString().split(' ')[0]}'),
                                    const SizedBox(height: 10),
                                    if (request['status'] == 'pending')
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () =>
                                                updateRequestStatus(
                                                    request['_id'], 'accepted'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
                                            ),
                                            child: const Text('Accept'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () =>
                                                updateRequestStatus(
                                                    request['_id'], 'rejected'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12),
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
