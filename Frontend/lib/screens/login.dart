import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectmoblie/screens/Home.dart';
import 'package:projectmoblie/screens/Lender.dart';
import 'package:projectmoblie/screens/Register.dart';
import 'package:projectmoblie/screens/staff.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _obscureText = true;
  final String url = '${dotenv.env['BASE_URL']}';
  bool isWaiting = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void popDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void login() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      popDialog('Error', 'Username and password are required.');
      return;
    }

    setState(() {
      isWaiting = true;
    });
    try {
      Uri uri = Uri.http(url, '/auth/login');
      Map account = {
        'username': _usernameController.text.trim(),
        'password': _passwordController.text.trim()
      };
      http.Response response = await http.post(
        uri,
        body: jsonEncode(account),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String token = responseData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        final jwt = JWT.decode(token);
        Map payload = jwt.payload;

        if (payload['exp'] != null &&
            DateTime.now().isAfter(
                DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000))) {
          popDialog('Error', 'Session expired, please login again.');
          await prefs.remove('token');
          return;
        }

        if (payload['role'] == 'lender') {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) => Lender()),
          );
        } else if (payload['role'] == 'staff') {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) => Staff()),
          );
        } else if (payload['role'] == 'borrower') {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (BuildContext context) => Home()),
          );
        }
      } else {
        popDialog('Error', 'Invalid username or password.');
      }
    } on TimeoutException catch (_) {
      popDialog('Error', 'Timeout error, try again!');
    } catch (e) {
      popDialog('Error', 'Unknown error, try again!');
    } finally {
      setState(() {
        isWaiting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to Sky Borrow Book',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5caee4),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60.0,
              backgroundImage: AssetImage('assets/images/logo.png'),
            ),
            const SizedBox(height: 20),

            // Username input
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: const TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password input
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: const TextStyle(color: Colors.blue),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2.0),
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: _togglePasswordView,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Login button
            IconButton(
              icon: const Icon(Icons.login),
              iconSize: 60,
              color: Colors.blue,
              onPressed: login,
            ),
            const SizedBox(height: 20),

            // Register link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
