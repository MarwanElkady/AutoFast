import 'package:autoelkady/Core/components/custom_button.dart';
import 'package:autoelkady/Core/components/custom_text.dart';
import 'package:autoelkady/Core/components/custom_text_field.dart';
import 'package:autoelkady/Features/Auth/RegistrationPage.dart';
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
  bool _obscurePassword = true;

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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Logged in Successfully")),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User Created Successfully")),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (c) => const Homepage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the app's primary color - red
    final Color primaryRed = Colors.red.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Logo and App Name
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryRed,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryRed.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.car_detailed,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomText(
                        text: "AUTO ELKADY",
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                      const SizedBox(height: 8),
                      CustomText(
                        text: isLogin
                            ? "Sign in to continue"
                            : "Create an account",
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Login Form Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: primaryRed.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form Title
                        Center(
                          child: CustomText(
                            text: isLogin ? "LOGIN" : "REGISTER",
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Email
                        const CustomText(
                          text: "Email",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _emailController,
                          hint: 'Enter your email',
                          type: TextInputType.emailAddress,
                          prefix: Icon(
                            CupertinoIcons.mail,
                            size: 20,
                            color: primaryRed,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password
                        const CustomText(
                          text: "Password",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: _passwordController,
                          hint: 'Enter your password',
                          type: TextInputType.text,
                          obscureText: _obscurePassword,
                          prefix: Icon(
                            CupertinoIcons.lock,
                            size: 20,
                            color: primaryRed,
                          ),
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? CupertinoIcons.eye_slash
                                  : CupertinoIcons.eye,
                              color: primaryRed.withOpacity(0.7),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _resetPassword,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: CustomText(
                              text: "Forgot password?",
                              fontSize: 14,
                              color: primaryRed,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Login / Register button
                        CustomButton(
                          onTap: _authenticate,
                          width: double.infinity,
                          height: 50,
                          color: primaryRed,
                          radius: 12,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isLogin
                                      ? CupertinoIcons.arrow_right_circle_fill
                                      : CupertinoIcons.person_add_solid,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                CustomText(
                                  text: isLogin ? "Sign In" : "Create Account",
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Switch between Login/Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: isLogin
                          ? "Don't have an account? "
                          : "Already have an account? ",
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                    TextButton(
                      onPressed: () {
                        if (isLogin) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegistrationPage(),
                            ),
                          );
                        } else {
                          setState(() => isLogin = true);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: CustomText(
                        text: isLogin ? "Sign Up" : "Sign In",
                        color: primaryRed,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                CustomText(
                  text: "powered by AutoElkady 2025",
                  fontSize: 12,
                  color: Colors.grey.withOpacity(1),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
