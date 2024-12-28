import 'package:flutter/material.dart';
import 'package:buyer_centric_app/services/firebase_service.dart';
import 'package:buyer_centric_app/screens/main_screen.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Colors for the app
  final Color primaryColor = const Color.fromARGB(255, 213, 247, 41);
  final Color contrastColor = Colors.grey.shade800;

  @override
  void dispose() {
    // Dispose of the controllers when the widget is disposed
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to sign up a new user
  Future<void> _signUp(BuildContext context) async {
    // Check if all fields are filled
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      // Show a snackbar with an error message
      _showSnackBar(context, 'All fields are required', Colors.red);
      return;
    }

    // Check if the email is valid
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text)) {
      // Show a snackbar with an error message
      _showSnackBar(context, 'Please enter a valid email address', Colors.red);
      return;
    }

    // Check if the passwords match
    if (passwordController.text != confirmPasswordController.text) {
      // Show a snackbar with an error message
      _showSnackBar(context, 'Passwords do not match', Colors.red);
      return;
    }

    // Check if the password is at least 6 characters long
    if (passwordController.text.length < 6) {
      // Show a snackbar with an error message
      _showSnackBar(
          context, 'Password must be at least 6 characters long', Colors.red);
      return;
    }

    try {
      // Sign up the user using Firebase
      await FirebaseService.signUpUser(
        emailController.text,
        passwordController.text,
        {
          'name': nameController.text,
          'email': emailController.text,
        },
      );

      // Navigate to the main screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MainScreen()),
        (route) => false,
      );
    } catch (e) {
      // Show a snackbar with an error message
      _showSnackBar(context, 'Failed to sign up: ${e.toString()}', Colors.red);
    }
  }

  // Function to show a snackbar with a message
  void _showSnackBar(BuildContext context, String message, Color color) {
    // Show a snackbar with the message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the sign up screen
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Container with a logo
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset('assets/tesla.png'),
                  ),
                ),
                // Text with the title
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: contrastColor,
                  ),
                ),
                SizedBox(height: 8),
                // Text with the subtitle
                Text(
                  'Sign up to get started',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 40),
                // Text field for full name
                _buildTextField('Full Name', Icons.person, nameController),
                SizedBox(height: 20),
                // Text field for email
                _buildTextField('Email', Icons.email, emailController),
                SizedBox(height: 20),
                // Text field for password
                _buildTextField('Password', Icons.lock, passwordController,
                    obscureText: true),
                SizedBox(height: 20),
                // Text field for confirm password
                _buildTextField('Confirm Password', Icons.lock_outline,
                    confirmPasswordController,
                    obscureText: true),
                SizedBox(height: 30),
                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _signUp(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: contrastColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Text with the login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: contrastColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Function to build a text field
  Widget _buildTextField(
      String label, IconData icon, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: contrastColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}
