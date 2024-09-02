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
  String _scoreMessage = '';
  String _studentPhone = '';
  String _studentLocation = '';

  // Fetch user data from 'exams' collection
  Future<Map<String, dynamic>?> _fetchExamData() async {
    try {
      // Split the formatted userId to separate id and academicGrade.
      final parts = widget.userId.split('_');
      if (parts.length < 2) {
        print('Invalid userId format. Expected "id_academicGrade".');
        return null;
      }

      final userId = int.tryParse(parts[0]);
      final academicGrade = parts[1];

      if (userId == null) {
        print('Invalid ID: ${parts[0]} is not a number.');
        return null;
      }

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
      final userId = int.parse(parts[0]);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('id', isEqualTo: userId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          _studentPhone = data['studentPhone'] ?? 'N/A';
          _studentLocation = data['location'] ?? 'N/A';
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
      final userId = int.parse(parts[0]);
      final academicGrade = parts[1];

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .where('id', isEqualTo: userId)
          .where('academicGrade', isEqualTo: academicGrade)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        var weekField = 'week$week'; // Example: 'week1', 'week2', etc.
        print('Fetching score from field: $weekField'); // Debugging line
        var score = data[weekField];
        setState(() {
          _scoreMessage = score != null
              ? 'The student got a score of: $score'
              : 'No score found for this week.';
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
      body: Container(
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
                        _buildUserInfoRow('Name', data['studentName'] ?? 'N/A'),
                        _buildUserInfoRow(
                            'Phone', _studentPhone), // Display student phone
                        _buildUserInfoRow('Location',
                            _studentLocation), // Display student location
                        _buildUserInfoRow(
                            'Senior', data['academicGrade'] ?? 'N/A'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Select Week',
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
                  const SizedBox(height: 20.0),
                  Text(
                    _scoreMessage,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }
          },
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
