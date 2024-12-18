import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:message_in_a_botlle/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  bool _isEulaAccepted = false;

  final String _termsUrl = "https://docs.google.com/document/d/1qK1md_FH9Ab74wnVLcyKQvZEj4BDX38a3-iAoHnyIJU/edit?usp=sharing";

  Future<String> _loadEulaContent() async {
    try {
      final file = rootBundle.loadString("assets/eula.txt");
      return await file;
    } catch (e) {
      return "Error loading EULA content: $e";
    }
  }

  void _showEulaPopup() async {
    final eulaContent = await _loadEulaContent();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("End User License Agreement (EULA)"),
          content: SingleChildScrollView(
            child: Text(eulaContent),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void handleShowPassword() => setState(() {
        isPasswordVisible = !isPasswordVisible;
      });

  void handleShowConfirmPassword() => setState(() {
        isConfirmPasswordVisible = !isConfirmPasswordVisible;
      });

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error!)),
        );
      }

      if (next.error == "User already exists") {
        context.go("/auth/login");
      }

      if (next.token != null) {
        context.go("/");
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: const BoxDecoration(
                // image: DecorationImage(image: NetworkImage("https://cdn.prod.website-files.com/63e25be3f4b49456411df88b/65f1d53651ddc736d6f88ce8_Exclusive%20Access.png"), opacity: 0.3, fit: BoxFit.fill),
                ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SignUp',
                          style: TextStyle(
                            color: Color(0xFF303030),
                            fontSize: 32,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            height: 0,
                          ),
                        ),
                        SizedBox(height: 16),
                        Opacity(
                          opacity: 0.75,
                          child: Text(
                            'Let’s get you all st up so you can access your personal account.',
                            style: TextStyle(
                              color: Color(0xFF303030),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(
                  height: 40,
                ),

                //   Sign up form
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: firstNameController,
                        decoration: InputDecoration(
                            label: const Text("First Name"),
                            hintText: "John",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your first name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: lastNameController,
                        decoration: InputDecoration(
                            label: const Text("Last Name"),
                            hintText: "Doe",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your last name";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                            label: const Text("Email"),
                            hintText: "jhondoe@gmail.com",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your email";
                          }

                          final emailRegex =
                              RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

                          if (!emailRegex.hasMatch(value)) {
                            return "Please enter a valid email";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: mobileController,
                        decoration: InputDecoration(
                            label: const Text("Phone Number"),
                            hintText: "+1234567890",
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5))),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your phone number";
                          }

                          final phoneRegex = RegExp(r'^\+?[0-9]{10,14}$');

                          if (!phoneRegex.hasMatch(value)) {
                            return 'Please enter a valid mobile number';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          label: const Text("Password"),
                          hintText: '•••••••••••••••••••••••••',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          suffixIcon: IconButton(
                            onPressed: handleShowPassword,
                            icon: Icon(isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter your password";
                          } else if (value.length < 6) {
                            return "Your password id too short";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: !isConfirmPasswordVisible,
                        decoration: InputDecoration(
                          label: const Text("Confirm Password"),
                          hintText: '•••••••••••••••••••••••••',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5)),
                          suffixIcon: IconButton(
                            onPressed: handleShowConfirmPassword,
                            icon: Icon(isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please confirm your password";
                          } else if (value.length < 6) {
                            return "Your password id too short";
                          } else if (value != passwordController.text) {
                            return "Passwords don not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: _isEulaAccepted,
                            onChanged: (value) {
                              setState(() {
                                _isEulaAccepted = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: [
                                  const TextSpan(text: "I accept the "),
                                  TextSpan(
                                    text: "Terms & Conditions",
                                    style: const TextStyle(color: Color(0xFFFF8682)),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (await canLaunchUrl(
                                            Uri.parse(_termsUrl))) {
                                          await launchUrl(Uri.parse(_termsUrl));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  "Could not open $_termsUrl"),
                                            ),
                                          );
                                        }
                                      },
                                  ),
                                  const TextSpan(text: " and the "),
                                  TextSpan(
                                    text: "EULA",
                                    style: const TextStyle(color: Color(0xFFFF8682)),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showEulaPopup,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                        onPressed: authState.isLoading
                            ? null
                            : () {
                                if (formKey.currentState!.validate()) {
                                  if (!_isEulaAccepted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "You must accept the EULA to proceed."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    ref.read(authProvider.notifier).signUp(
                                        firstName: firstNameController.text,
                                        lastname: lastNameController.text,
                                        email: emailController.text,
                                        mobile: mobileController.text,
                                        password: passwordController.text);

                                    context.go("/");
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: authState.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Create Account",
                                style: TextStyle(color: Colors.white),
                              ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(
                      width: 4,
                    ),
                    InkWell(
                      onTap: () {
                        context.push("/auth/login");
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Color(0xFFFF8682)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
