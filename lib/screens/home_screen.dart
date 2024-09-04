import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final String userId; // Pass the user ID to the HomeScreen

  const HomeScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedWeek;
  int? _selectedAttendanceWeek;
  int? _selectedPaymentWeek;
  String _scoreMessage = '';
  String _attendanceMessage = '';
  String _paymentMessage = '';
  String _studentPhone = '';
  String _studentLocation = '';
  String _name = '';
  Color _attendanceColor = Colors.black;

  // Fetch user data from 'exams' collection
  Future<Map<String, dynamic>?> _fetchExamData() async {
    try {
      // Split the formatted userId to separate id and academicGrade.
      final parts = widget.userId.split('_');
      if (parts.length < 2) {
        print('Invalid userId format. Expected "id_academicGrade".');
        return null;
      }

      final userId = parts[0]; // id is a string
      final academicGrade = parts[1];

      print(
          'Fetching data for User ID: $userId, Academic Grade: $academicGrade');

      // Query Firestore to match the correct 'id' and 'academicGrade'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .where('id', isEqualTo: userId)
          .where('academicGrade', isEqualTo: academicGrade)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('Found exam data for user');
        return querySnapshot.docs.first.data() as Map<String, dynamic>;
      } else {
        print('Exam data not found for user');
        return null;
      }
    } catch (e) {
      print('Error fetching exam data: $e');
      return null;
    }
  }

  // Fetch user data from 'students' collection
  Future<void> _fetchStudentData() async {
    try {
      final parts = widget.userId.split('_');
      final userId = parts[0]; // id is a string

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('id', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        print('Fetched student data: $data'); // Debugging line
        setState(() {
          _studentPhone = data['studentPhone'] ?? 'N/A';
          _studentLocation = data['location'] ?? 'N/A';
          _name = data['name'] ??
              'N/A'; // Use the 'name' field from students collection
        });
      } else {
        print('Student data not found for user');
      }
    } catch (e) {
      print('Error fetching student data: $e');
    }
  }

  Future<void> _fetchScore(int week) async {
    try {
      final parts = widget.userId.split('_');
      final userId = parts[0]; // id is a string
      final academicGrade = parts[1];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .where('id', isEqualTo: userId)
          .where('academicGrade', isEqualTo: academicGrade)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        var examData = data['exams'] as List<dynamic>; // List of exam records
        var weekData = examData.firstWhere((exam) => exam['week'] == week,
            orElse: () => {'score': 'N/A'}); // Default to 'N/A' if not found
        setState(() {
          _scoreMessage = 'The student got a score of: ${weekData['score']}';
        });
      } else {
        setState(() {
          _scoreMessage = 'Exam data not found for user.';
        });
      }
    } catch (e) {
      print('Error fetching score: $e');
      setState(() {
        _scoreMessage = 'Error fetching score.';
      });
    }
  }

  Future<void> _fetchAttendance(int week) async {
    try {
      final parts = widget.userId.split('_');
      final userId = parts[0]; // id is a string

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('id', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        var attendanceData =
            data['attendance'] as List<dynamic>; // List of attendance records
        var weekData = attendanceData.firstWhere(
            (attendance) => attendance['week'] == week,
            orElse: () => {'status': 'N/A'}); // Default to 'N/A' if not found
        setState(() {
          if (weekData['status'] == 1) {
            _attendanceMessage = 'Present';
            _attendanceColor = Colors.green;
          } else if (weekData['status'] == 0) {
            _attendanceMessage = 'Absent';
            _attendanceColor = Colors.red;
          } else {
            _attendanceMessage = 'N/A';
            _attendanceColor = Colors.black;
          }
        });
      } else {
        setState(() {
          _attendanceMessage = 'Attendance data not found for user.';
          _attendanceColor = Colors.black;
        });
      }
    } catch (e) {
      print('Error fetching attendance: $e');
      setState(() {
        _attendanceMessage = 'Error fetching attendance.';
        _attendanceColor = Colors.black;
      });
    }
  }

  Future<void> _fetchPayment(int week) async {
    try {
      final parts = widget.userId.split('_');
      final userId = parts[0]; // id is a string

      // Query the Firestore 'payments' collection using the userId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('payments')
          .where('id', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        var paymentData =
            data['payments'] as List<dynamic>; // List of payment records

        // Find the payment data for the specified week
        var weekData = paymentData.firstWhere(
            (payment) => payment['week'] == week,
            orElse: () => {'paid': 'false'}); // Default to 'false' if not found

        // Get the 'paid' value directly from Firestore
        String paidStatus = weekData['paid'] ?? 'false';

        // Update the state to reflect the payment status
        setState(() {
          _paymentMessage = 'Payment status for week $week: $paidStatus';
        });
      } else {
        setState(() {
          _paymentMessage = 'Payment data not found for user.';
        });
      }
    } catch (e) {
      print('Error fetching payment: $e');
      setState(() {
        _paymentMessage = 'Not paid yet';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStudentData(); // Fetch student data initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color(0xFF4A90E2), // New AppBar color
      ),
      backgroundColor: const Color(0xFFE5E5E5), // New Scaffold background color
      body: SingleChildScrollView(
        child: Container(
          color: const Color(0xFFF5F5F5), // New Container background color
          padding: const EdgeInsets.all(20.0),
          child: FutureBuilder<Map<String, dynamic>?>(
            future: _fetchExamData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: const Text('Exam data not found.'));
              } else {
                final data = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10.0,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.person,
                            size: 50.0, // Smaller icon size
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 20.0),
                          _buildUserInfoRow(
                              'ID', data['id']?.toString() ?? 'N/A'),
                          _buildUserInfoRow(
                              'Name', _name), // Display student name
                          _buildUserInfoRow('Phone', _studentPhone),
                          _buildUserInfoRow('Location', _studentLocation),
                          _buildUserInfoRow(
                              'Senior', data['academicGrade'] ?? 'N/A'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Week for Score',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      value: _selectedWeek,
                      items: List.generate(40, (index) => index + 1)
                          .map((week) => DropdownMenuItem<int>(
                                value: week,
                                child: Text('Week $week'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedWeek = value;
                        });
                        if (value != null) {
                          _fetchScore(value);
                        }
                      },
                    ),
                    const SizedBox(height: 29.0), // Reduced distance
                    Transform.translate(
                      offset: Offset(0,
                          -10), // Adjust the vertical offset for score message
                      child: Text(
                        _scoreMessage,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0), // Reduced distance
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Week for Attendance',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      value: _selectedAttendanceWeek,
                      items: List.generate(40, (index) => index + 1)
                          .map((week) => DropdownMenuItem<int>(
                                value: week,
                                child: Text('Week $week'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAttendanceWeek = value;
                        });
                        if (value != null) {
                          _fetchAttendance(value);
                        }
                      },
                    ),
                    const SizedBox(height: 29.0), // Reduced distance
                    Transform.translate(
                      offset: Offset(0,
                          -10), // Adjust the vertical offset as needed (negative for upward, positive for downward)
                      child: Text(
                        _attendanceMessage,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: _attendanceColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20.0), // Reduced distance
                    DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Select Week for Payment',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      value: _selectedPaymentWeek,
                      items: List.generate(40, (index) => index + 1)
                          .map((week) => DropdownMenuItem<int>(
                                value: week,
                                child: Text('Week $week'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentWeek = value;
                        });
                        if (value != null) {
                          _fetchPayment(value);
                        }
                      },
                    ),
                    const SizedBox(height: 29.0), // Reduced distance
                    Transform.translate(
                      offset: Offset(0,
                          -10), // Adjust the vertical offset for payment message
                      child: Text(
                        _paymentMessage,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0, // Increased font size
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18.0, // Increased font size
            ),
          ),
        ],
      ),
    );
  }
}
