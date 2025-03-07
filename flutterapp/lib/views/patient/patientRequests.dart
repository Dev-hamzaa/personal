import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterapp/components/header.dart';

class PatientRequests extends StatefulWidget {
  const PatientRequests({super.key});

  @override
  State<PatientRequests> createState() => _PatientRequestsState();
}

class _PatientRequestsState extends State<PatientRequests> {
  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatientRequests();
  }

  Future<void> fetchPatientRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) {
        throw 'User ID not found';
      }

      final response = await http.get(
        Uri.parse('${Endpoints.baseUrl}api/request/?patientId=$userId'),
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

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '#FFA500'; // Orange
      case 'accepted':
        return '#4CAF50'; // Green
      case 'rejected':
        return '#F44336'; // Red
      default:
        return '#757575'; // Grey
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : requests.isEmpty
                      ? const Center(child: Text('No requests found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Request #${index + 1}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(
                                              int.parse(
                                                _getStatusColor(
                                                        request['status'])
                                                    .replaceAll('#', '0xFF'),
                                              ),
                                            ).withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            request['status'] ?? 'Unknown',
                                            style: TextStyle(
                                              color: Color(
                                                int.parse(
                                                  _getStatusColor(
                                                          request['status'])
                                                      .replaceAll('#', '0xFF'),
                                                ),
                                              ),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Icon(Icons.medical_services,
                                            color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Requested Organ: ${request['requestedOrgan'] ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (request['bloodType'] != null)
                                      Row(
                                        children: [
                                          Icon(Icons.bloodtype,
                                              color: Colors.grey[600]),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Blood Type: ${request['bloodType']}',
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Requested on: ${DateTime.parse(request['createdAt']).toLocal().toString().split(' ')[0]}',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
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
    );
  }
}
