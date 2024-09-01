import 'package:flutter/material.dart';
import 'package:parentsapp/screens/signin_screen.dart';
import 'package:parentsapp/widgets/custom_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Center all children vertically
        children: [
          Expanded(
            flex: 7, // Adjust this value as needed
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 40.0,
              ),
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Welcome Back!!\n',
                        style: TextStyle(
                          fontSize: 45.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text:
                            '\nEnter personal details to your employee account',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Add space above the button
          Padding(
            padding: const EdgeInsets.only(
                top: 20.0), // Adjust padding to move the button higher
            child: SizedBox(
              width: double.infinity, // Make the button fill the width
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.transparent, // Set button background color
                  foregroundColor: Colors.white, // Set text color
                  minimumSize: const Size(
                      double.infinity, 50), // Make the button a bit taller
                  textStyle: const TextStyle(
                    fontSize: 24, // Set the font size of the button text
                    fontWeight: FontWeight.bold, // Optional: make the text bold
                  ),
                ),
                child: const Text('Login'),
              ),
            ),
          ),
          const SizedBox(height: 20), // Extra space below the button
        ],
      ),
    );
  }
}
