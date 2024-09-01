import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formSignInKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  String? _selectedSenior;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Column(
        children: [
          const Expanded(
            flex: 1,
            child: SizedBox(height: 10),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formSignInKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 40.0),
                      _buildTextField(),
                      const SizedBox(height: 25.0),
                      _buildDropdownButton(),
                      const SizedBox(height: 25.0),
                      _buildSignInButton(context),
                      const SizedBox(height: 25.0),
                      _buildDivider(),
                      const SizedBox(height: 25.0),
                      _buildRegisterButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      controller: _idController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter ID';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'ID',
        hintText: 'Enter ID',
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDropdownButton() {
    return DropdownButtonFormField<String>(
      value: _selectedSenior,
      items: ['senior 1', 'senior 2', 'senior 3']
          .map((senior) => DropdownMenuItem<String>(
                value: senior,
                child: Text(senior),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedSenior = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a senior';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Senior',
        hintText: 'Select Senior',
        hintStyle: const TextStyle(color: Colors.black26),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return _isLoading
        ? const CircularProgressIndicator()
        : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (_formSignInKey.currentState!.validate()) {
                  setState(() => _isLoading = true);

                  // Print debug information for user inputs
                  print('ID: ${_idController.text.trim()}');
                  print('Selected Senior: $_selectedSenior');

                  // Call validation function with trimmed input values
                  bool isValid = await _validateUser(
                    _idController.text.trim(),
                    _selectedSenior!,
                  );

                  setState(() => _isLoading = false);

                  if (isValid) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomeScreen(
                            userId: _idController.text
                                .trim()), // Pass actual user ID here
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Invalid ID or Senior. Try again.')),
                    );
                  }
                }
              },
              child: const Text('Sign in'),
            ),
          );
  }

  Widget _buildDivider() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            thickness: 0.7,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Text('or'),
        ),
        Expanded(
          child: Divider(
            thickness: 0.7,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register button pressed')),
        );
      },
      child: const Text('Register'),
    );
  }

  Future<bool> _validateUser(String id, String academicGrade) async {
    try {
      // Convert the ID to an integer
      int idAsInt;
      try {
        idAsInt = int.parse(id.trim());
      } catch (e) {
        print('Invalid ID format');
        return false;
      }

      // Trim the academicGrade
      academicGrade = academicGrade.trim();

      print(
          'Validating User with ID: $idAsInt and Academic Grade: $academicGrade');

      // Query Firestore for matching 'id' and 'academicGrade'
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('exams')
          .where('id', isEqualTo: idAsInt)
          .where('academicGrade', isEqualTo: academicGrade)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        print('Matching record found');
        return true; // A matching record is found
      } else {
        print('No matching record found');
        return false;
      }
    } catch (e) {
      print('Error validating user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error validating user: $e')),
      );
      return false;
    }
  }
}
