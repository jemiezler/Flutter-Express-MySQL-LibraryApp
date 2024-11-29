import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> _registerUser(String name, String username, String password,
    String phoneNumber, BuildContext context) async {
  final url = Uri.parse('http://${dotenv.env['BASE_URL']}:5001/register');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'password': password,
        'phone_number': phoneNumber,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      _showMessage(context, 'User registered successfully!', true);
    } else {
      // Handle different status codes here
      String errorMessage = 'Failed to register user';
      try {
        final errorResponse = jsonDecode(response.body);
        if (errorResponse != null && errorResponse['message'] != null) {
          errorMessage = errorResponse['message'];
        }
      } catch (e) {
        // If the body is not JSON, fallback to a general error message
        print('Error parsing JSON: $e');
      }
      _showMessage(context, errorMessage, false);
    }
  } catch (error) {
    // Handle different types of errors: network issues, invalid URL, etc.
    String errorMessage = 'Error registering user';
    if (error is http.ClientException) {
      errorMessage = 'Network error: Unable to reach server';
    } else if (error is FormatException) {
      errorMessage = 'Invalid response format';
    }
    _showMessage(context, '$errorMessage: $error', false);
  }
}

void _showMessage(BuildContext context, String message, bool success) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(success ? 'Success' : 'Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _submitRegistration() {
    final name = _nameController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final phoneNumber = _phoneNumberController.text;

    if (password != confirmPassword) {
      _showMessage(context, 'Passwords do not match', false);
      return;
    }

    _registerUser(name, username, password, phoneNumber, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        centerTitle: true,
        backgroundColor: Color(0xFF5caee4),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name - Lastname',
                labelStyle: TextStyle(
                  color: Colors.blue,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(
                  color: Colors.blue,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordView,
                ),
                labelStyle: TextStyle(
                  color: Colors.blue,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(
                  color: Colors.blue,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 4),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(
                labelText: 'Phone number',
                labelStyle: TextStyle(
                  color: Colors.blue,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 20),
            IconButton(
              icon: Icon(Icons.app_registration_rounded),
              iconSize: 60,
              color: Colors.blue,
              onPressed: _submitRegistration,
            ),
          ],
        ),
      ),
    );
  }
}
