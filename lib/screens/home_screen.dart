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

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('exams')
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        print('User not found');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<void> _fetchScore(int week) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(
              'exams') // Ensure this matches your Firestore collection name
          .doc(widget.userId)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
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
          _scoreMessage = 'User not found.';
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
          future: _fetchUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: const Text('User data not found.'));
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
                        _buildUserInfoRow('Phone', data['phone'] ?? 'N/A'),
                        _buildUserInfoRow(
                            'Location', data['location'] ?? 'N/A'),
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
