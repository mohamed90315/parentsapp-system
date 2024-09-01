import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key});

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
        child: Column(
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
                  _buildUserInfoRow('ID', '12345'),
                  _buildUserInfoRow('Name', 'John Doe'),
                  _buildUserInfoRow('Phone', '+1234567890'),
                  _buildUserInfoRow('Location', 'New York, USA'),
                  _buildUserInfoRow('Senior', 'Senior 1'),
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
              items: List.generate(40, (index) => index + 1)
                  .map((week) => DropdownMenuItem<int>(
                        value: week,
                        child: Text('Week $week'),
                      ))
                  .toList(),
              onChanged: (value) {
                // Handle week selection
              },
            ),
          ],
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
