import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> _bookedTimeSlots = [];

  @override
  void initState() {
    super.initState();
    // Set initial selected day to today
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    fetchDoctorDetails();
    // Check existing appointments for today
    checkExistingAppointments();
    // Fetch all patient appointments
    fetchPatientAppointments();
  }

  // Generate time slots based on start and end time
  List<String> generateTimeSlots(String startTime, String endTime) {
    List<String> slots = [];

    // Print input times
    print('Generating slots from: $startTime to: $endTime');

    // Parse the times from AM/PM format
    List<String> startParts = startTime.split(' ');
    List<String> endParts = endTime.split(' ');

    // Parse start time
    List<String> startTimeParts = startParts[0].split(':');
    int startHour = int.parse(startTimeParts[0]);
    int startMinute = int.parse(startTimeParts[1]);
    bool startIsPM = startParts[1] == 'PM';

    // Parse end time
    List<String> endTimeParts = endParts[0].split(':');
    int endHour = int.parse(endTimeParts[0]);
    int endMinute = int.parse(endTimeParts[1]);
    bool endIsPM = endParts[1] == 'PM';

    // Convert to 24-hour format
    if (startIsPM && startHour != 12) startHour += 12;
    if (!startIsPM && startHour == 12) startHour = 0;

    if (endIsPM && endHour != 12) endHour += 12;
    if (!endIsPM && endHour == 12) endHour = 0;

    // Handle case where end time is on the next day
    if (endHour < startHour) {
      endHour += 24;
    }

    // Generate slots with 1-hour intervals
    int currentHour = startHour;
    while (currentHour < endHour) {
      int displayHour = currentHour % 24;
      String period = displayHour >= 12 ? 'PM' : 'AM';
      if (displayHour > 12) displayHour -= 12;
      if (displayHour == 0) displayHour = 12;

      String slot = '${displayHour.toString().padLeft(2, '0')}:00 $period';
      print('Adding slot: $slot');
      slots.add(slot);
      currentHour++;
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
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
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
          // After loading doctor details, update available time slots for today
          updateAvailableTimeSlots();
        } else {
          throw 'Failed to fetch doctor details';
        }
      } else {
        throw 'Failed to fetch doctor details';
      }
    } catch (e) {
      print('Error fetching doctor details: $e');
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

  Future<bool> checkExistingAppointments() async {
    try {
      // Format the date to match API requirements (YYYY-MM-DD)
      String formattedDate =
          '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';

      print(
          'Checking existing appointments for doctor: ${widget.doctorId} on date: $formattedDate');

      final response = await http.get(
        Uri.parse(
            '${Endpoints.getAppointments}?doctor=${widget.doctorId}&date=$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('\n=== Existing Appointments Response ===');
        print('Success: ${responseData['success']}');
        print('Message: ${responseData['message']}');
        print('Data: ${json.encode(responseData['data'])}');
        print('=====================================\n');

        if (responseData['success'] == true) {
          List<dynamic> appointments = responseData['data'] ?? [];
          // Update the list of booked time slots
          setState(() {
            _bookedTimeSlots = appointments
                .map((appointment) => appointment['time'] as String)
                .toList();
          });
          print('Booked time slots: $_bookedTimeSlots');
          return _bookedTimeSlots.contains(_selectedTimeSlot);
        }
      }
      return false;
    } catch (e) {
      print('Error checking existing appointments: $e');
      return false;
    }
  }

  Future<void> fetchPatientAppointments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getString('userId');

      if (patientId == null) {
        throw 'Patient ID not found';
      }

      print('Fetching appointments for patient: $patientId');

      final response = await http.get(
        Uri.parse('${Endpoints.getAppointments}?patient=$patientId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('\n=== Patient Appointments Response ===');
        print('Success: ${responseData['success']}');
        print('Message: ${responseData['message']}');
        print('Data: ${json.encode(responseData['data'])}');
        print('=====================================\n');
      }
    } catch (e) {
      print('Error fetching patient appointments: $e');
    }
  }

  Future<void> bookAppointment() async {
    try {
      // First check if the time slot is already booked
      bool isTimeSlotBooked = await checkExistingAppointments();
      if (isTimeSlotBooked) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'This time slot is already booked. Please select another time.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get patient ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final patientId = prefs.getString('userId');

      if (patientId == null) {
        throw 'Patient ID not found';
      }

      // Format the date to match API requirements (YYYY-MM-DD)
      String formattedDate =
          '${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}';

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'doctorId': widget.doctorId,
        'patientId': patientId,
        'appointmentDate': formattedDate,
        'time': _selectedTimeSlot,
      };

      print('Booking appointment with data: $requestBody');
      print('Making POST request to: ${Endpoints.bookAppointment}');

      final response = await http.post(
        Uri.parse(Endpoints.bookAppointment),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appointment booked successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Fetch updated patient appointments
          await fetchPatientAppointments();
          // Navigate back to previous screen
          Navigator.pop(context);
        } else {
          throw responseData['message'] ?? 'Failed to book appointment';
        }
      } else {
        throw 'Failed to book appointment';
      }
    } catch (e) {
      print('Error booking appointment: $e');
      if (!mounted) return;
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
                                lastDay: DateTime.now()
                                    .add(const Duration(days: 30)),
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) =>
                                    _selectedDay != null &&
                                    isSameDay(_selectedDay!, day),
                                onDaySelected: (selectedDay, focusedDay) async {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                    updateAvailableTimeSlots();
                                  });
                                  // Check existing appointments for selected date
                                  await checkExistingAppointments();
                                },
                                calendarFormat: CalendarFormat.week,
                                headerStyle: const HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: TextStyle(fontSize: 16),
                                  leftChevronIcon:
                                      Icon(Icons.chevron_left, size: 20),
                                  rightChevronIcon:
                                      Icon(Icons.chevron_right, size: 20),
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
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    mainAxisExtent: 40,
                                  ),
                                  itemCount: _availableTimeSlots.length,
                                  itemBuilder: (context, index) {
                                    final timeSlot = _availableTimeSlots[index];
                                    final isSelected =
                                        timeSlot == _selectedTimeSlot;
                                    final isBooked =
                                        _bookedTimeSlots.contains(timeSlot);

                                    return Material(
                                      color: isBooked
                                          ? Colors.grey[400]
                                          : isSelected
                                              ? Theme.of(context).primaryColor
                                              : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: isBooked
                                            ? null
                                            : () {
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
                                              color: isBooked
                                                  ? Colors.white70
                                                  : isSelected
                                                      ? Colors.white
                                                      : Colors.black,
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
                                bookAppointment();
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
