import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';

class AppointmentBookingView extends StatefulWidget {
  final String doctorId;
  final String doctorName;

  const AppointmentBookingView({
    super.key, 
    required this.doctorId,
    required this.doctorName,
  });

  @override
  State<AppointmentBookingView> createState() => _AppointmentBookingViewState();
}

class _AppointmentBookingViewState extends State<AppointmentBookingView> {
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  String? _selectedTimeSlot;
  bool isLoading = true;
  Map<String, dynamic> doctorDetails = {};
  List<String> _availableTimeSlots = [];
  
  @override
  void initState() {
    super.initState();
    fetchDoctorDetails();
  }

  // Generate time slots based on start and end time
  List<String> generateTimeSlots(String startTime, String endTime) {
    List<String> slots = [];
    
    // Print input times
    print('Generating slots from: $startTime to: $endTime');
    
    // Parse the times from ISO format
    DateTime start = DateTime.parse(startTime);
    DateTime end = DateTime.parse(endTime);
    
    print('Parsed start time: ${start.toString()}');
    print('Parsed end time: ${end.toString()}');

    // Generate slots with 1-hour intervals
    DateTime current = start;
    while (current.isBefore(end)) {
      String slot = '${current.hour.toString().padLeft(2, '0')}:00';
      print('Adding slot: $slot');
      slots.add(slot);
      current = current.add(const Duration(hours: 1));
    }

    print('Generated slots: $slots');
    return slots;
  }

  // Get available time slots for selected day
  void updateAvailableTimeSlots() {
    if (_selectedDay == null || doctorDetails['weeklySchedule'] == null) {
      print('No selected day or weekly schedule');
      _availableTimeSlots = [];
      return;
    }

    // Get day of week name
    String selectedDayName = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ][_selectedDay!.weekday - 1];

    print('Selected day: $selectedDayName');
    print('Weekly Schedule: ${doctorDetails['weeklySchedule']}');

    // Find matching schedule
    var schedule = (doctorDetails['weeklySchedule'] as List).firstWhere(
      (schedule) => schedule['day'] == selectedDayName,
      orElse: () => null,
    );

    if (schedule != null) {
      print('Found schedule for $selectedDayName: $schedule');
      _availableTimeSlots = generateTimeSlots(
        schedule['start'],
        schedule['end'],
      );
      print('Final available time slots: $_availableTimeSlots');
    } else {
      print('No schedule found for $selectedDayName');
      _availableTimeSlots = [];
    }

    // Reset selected time slot
    _selectedTimeSlot = null;
  }

  Future<void> fetchDoctorDetails() async {
    try {
      print('Fetching doctor details for ID: ${widget.doctorId}');
      
      final response = await http.get(
        Uri.parse('${Endpoints.getDoctorDetails}/${widget.doctorId}'),
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
            doctorDetails = responseData['data'];
            isLoading = false;
          });
        } else {
          throw 'Failed to fetch doctor details';
        }
      } else {
        throw 'Failed to fetch doctor details';
      }
    } catch (e) {
      print('Error fetching doctor details: $e');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: SafeArea(
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          // Doctor Details Card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dr. ${doctorDetails['name'] ?? widget.doctorName}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Specialization: ${doctorDetails['specialization'] ?? 'Not specified'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Calendar
                          Card(
                            child: TableCalendar(
                              firstDay: DateTime.now(),
                              lastDay: DateTime.now().add(const Duration(days: 30)),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) => 
                                  _selectedDay != null && isSameDay(_selectedDay!, day),
                              onDaySelected: (selectedDay, focusedDay) {
                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                  updateAvailableTimeSlots();
                                });
                              },
                              calendarFormat: CalendarFormat.week,
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                titleTextStyle: TextStyle(fontSize: 16),
                                leftChevronIcon: Icon(Icons.chevron_left, size: 20),
                                rightChevronIcon: Icon(Icons.chevron_right, size: 20),
                              ),
                              availableCalendarFormats: const {
                                CalendarFormat.week: 'Week',
                              },
                              calendarStyle: const CalendarStyle(
                                outsideDaysVisible: false,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Time Slots
                          if (_selectedDay != null) ...[
                            if (_availableTimeSlots.isNotEmpty) ...[
                              const Text(
                                'Available Time Slots',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                  mainAxisExtent: 40,
                                ),
                                itemCount: _availableTimeSlots.length,
                                itemBuilder: (context, index) {
                                  final timeSlot = _availableTimeSlots[index];
                                  final isSelected = timeSlot == _selectedTimeSlot;
                                  
                                  return Material(
                                    color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedTimeSlot = timeSlot;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: Text(
                                          timeSlot,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ] else
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'No available time slots for this day',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                          ] else
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'Please select a date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Book Button
                    if (_selectedDay != null && _selectedTimeSlot != null)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Booking appointment for ${_selectedDay.toString().split(' ')[0]} at $_selectedTimeSlot',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Book Appointment',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
      ),
    );
  }
}
