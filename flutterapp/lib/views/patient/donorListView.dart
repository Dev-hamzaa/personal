import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutterapp/components/header.dart';

class DonorListView extends StatefulWidget {
  const DonorListView({super.key});

  @override
  State<DonorListView> createState() => _DonorListViewState();
}

class _DonorListViewState extends State<DonorListView> {
  List<dynamic> donors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDonors();
  }

  Future<void> fetchDonors() async {
    try {
      final response = await http.get(
        Uri.parse(Endpoints.getAllDonors),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          setState(() {
            donors = responseData['data'];
            isLoading = false;
          });
        } else {
          throw responseData['message'] ?? 'Failed to fetch donors';
        }
      } else {
        throw 'Failed to fetch donors';
      }
    } catch (e) {
      print('Error fetching donors: $e');
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

  Widget _buildOrganChip(String organ) {
    return Container(
      margin: const EdgeInsets.only(right: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        organ,
        style: TextStyle(
          color: Colors.blue[900],
          fontSize: 12,
        ),
      ),
    );
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
                  : donors.isEmpty
                      ? const Center(child: Text('No donors available'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: donors.length,
                          itemBuilder: (context, index) {
                            final donor = donors[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Profile Picture Section (Commented Out)
                                    /*
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blue[100],
                                          radius: 30,
                                          child: const Icon(Icons.person,
                                              size: 30, color: Colors.blue),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                donor['name'] ?? 'Unknown',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                donor['email'] ?? 'N/A',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    const SizedBox(height: 16),
                                    */

                                    // Donor Information
                                    Text(
                                      donor['name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.email,
                                            color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text(
                                          donor['email'] ?? 'N/A',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.phone,
                                            color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text(
                                          donor['phone'] ?? 'N/A',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.bloodtype,
                                            color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Blood Group: ${donor['bloodType'] ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.medical_services,
                                            color: Colors.grey[600]),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Organs to Donate: ${donor['selectedOrgan']?.join(',') ?? 'N/A'}',
                                          style: TextStyle(
                                            color: Colors.grey[800],
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          // Show dialog for selecting blood type and organ
                                          final result = await showDialog<
                                              Map<String, dynamic>>(
                                            context: context,
                                            builder: (BuildContext context) {
                                              String selectedBloodType = '';
                                              String selectedOrgan = '';
                                              return AlertDialog(
                                                title: const Text(
                                                    'Select Details'),
                                                content: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Blood Type Dropdown
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child:
                                                          DropdownButtonFormField<
                                                              String>(
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          prefixIcon: Icon(
                                                              Icons.bloodtype),
                                                        ),
                                                        hint: const Text(
                                                            'Select Blood Type (Optional)'),
                                                        value: selectedBloodType
                                                                .isEmpty
                                                            ? null
                                                            : selectedBloodType,
                                                        items:
                                                            donor['bloodType'] !=
                                                                    null
                                                                ? [
                                                                    DropdownMenuItem<
                                                                        String>(
                                                                      value: '',
                                                                      child:
                                                                          Text(
                                                                        'Clear',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[600],
                                                                          fontStyle:
                                                                              FontStyle.italic,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    DropdownMenuItem<
                                                                        String>(
                                                                      value: donor[
                                                                          'bloodType'],
                                                                      child: Text(
                                                                          donor[
                                                                              'bloodType']),
                                                                    ),
                                                                  ]
                                                                : [],
                                                        onChanged: (value) {
                                                          selectedBloodType =
                                                              value ?? '';
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(height: 16),
                                                    // Organ Dropdown
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12),
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .grey.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child:
                                                          DropdownButtonFormField<
                                                              String>(
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          prefixIcon: Icon(Icons
                                                              .volunteer_activism),
                                                        ),
                                                        hint: const Text(
                                                            'Select Organ'),
                                                        value: selectedOrgan
                                                                .isEmpty
                                                            ? null
                                                            : selectedOrgan,
                                                        items: [
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: '',
                                                            child: Text(
                                                              'Clear',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                                fontStyle:
                                                                    FontStyle
                                                                        .italic,
                                                              ),
                                                            ),
                                                          ),
                                                          ...(donor['selectedOrgan']
                                                                      as List<
                                                                          dynamic>?)
                                                                  ?.map((dynamic
                                                                      value) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: value
                                                                      .toString(),
                                                                  child: Text(value
                                                                      .toString()),
                                                                );
                                                              }).toList() ??
                                                              [],
                                                        ],
                                                        onChanged: (value) {
                                                          selectedOrgan =
                                                              value ?? '';
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      if (selectedOrgan
                                                              .isEmpty &&
                                                          selectedBloodType
                                                              .isEmpty) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Please select either blood type or organ'),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      Navigator.of(context)
                                                          .pop({
                                                        'bloodType':
                                                            selectedBloodType,
                                                        'organ': selectedOrgan,
                                                      });
                                                    },
                                                    child: const Text(
                                                        'Send Request'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (result != null) {
                                            try {
                                              // Get current user ID from SharedPreferences
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              final userId =
                                                  prefs.getString('userId');

                                              if (userId == null) {
                                                throw 'User ID not found';
                                              }

                                              // Create request data
                                              final requestData = {
                                                'patientId': userId,
                                                'donorId': donor['_id'],
                                                'requestedOrgan':
                                                    result['organ'],
                                                if (result['bloodType']
                                                        ?.isNotEmpty ??
                                                    false)
                                                  'bloodType':
                                                      result['bloodType'],
                                              };

                                              print(
                                                  'Sending request with data: ${json.encode(requestData)}');

                                              // Make API call to create request
                                              final response = await http.post(
                                                Uri.parse(
                                                    '${Endpoints.baseUrl}api/request/'),
                                                headers: {
                                                  'Content-Type':
                                                      'application/json',
                                                },
                                                body: json.encode(requestData),
                                              );

                                              print(
                                                  'Response status: ${response.statusCode}');
                                              print(
                                                  'Response body: ${response.body}');

                                              if (response.statusCode == 200) {
                                                final responseData =
                                                    json.decode(response.body);
                                                if (responseData['success'] ==
                                                    true) {
                                                  if (!mounted) return;
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Request sent successfully!'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                } else {
                                                  throw responseData[
                                                          'message'] ??
                                                      'Failed to create request';
                                                }
                                              } else {
                                                throw 'Failed to create request';
                                              }
                                            } catch (e) {
                                              print(
                                                  'Error creating request: $e');
                                              if (!mounted) return;
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $e'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                        child: const Text('Send Request'),
                                      ),
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
