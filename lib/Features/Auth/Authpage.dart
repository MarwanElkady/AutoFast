import 'package:autoelkady/Core/components/custom_button.dart';
import 'package:autoelkady/Core/components/custom_text.dart';
import 'package:autoelkady/Core/components/custom_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:autoelkady/Features/Home/HomePage.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLogin = true;

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email first")),
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset email sent to $email")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _authenticate() async {
    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Logged in Successfully")),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Created Successfully")),
        );
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const Homepage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(backgroundColor: Colors.grey.shade300, toolbarHeight: 0),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const Icon(CupertinoIcons.lock, color: Colors.black, size: 100),
            const SizedBox(height: 30),

            // Email
            CustomTextField(
              controller: _emailController,
              hint: 'Email',
              type: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),

            // Password
            CustomTextField(
              controller: _passwordController,
              hint: 'Password',
              type: TextInputType.text,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _resetPassword,
                child: const CustomText(
                  text: "Forgot password?",
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Login / Register button
            CustomButton(
              onTap: _authenticate,
              width: double.infinity,
              height: 45,
              color: Colors.black,
              radius: 8,
              child: Center(
                child: CustomText(
                  text: isLogin ? "Login" : "Register",
                  color: Colors.grey.shade300,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Switch between Login/Register
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: CustomText(
                text: isLogin
                    ? "Create an account"
                    : "Already have an account? Login",
                color: Colors.black,
                fontSize: 15,
              ),
            ),

            const Spacer(),
            const CustomText(text: "powered by AutoElkady 2025"),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
