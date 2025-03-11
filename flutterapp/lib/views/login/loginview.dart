import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/consts/images.dart';
import 'package:flutterapp/consts/strings.dart';
import 'package:flutterapp/views/login/signupview.dart';
import 'package:flutterapp/views/navigationBar.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutterapp/consts/endPoints.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Add controllers for email and password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // Add login function
  Future<void> loginCall(BuildContext context) async {
    if (isLoading) return; // Prevent multiple calls

    try {
      setState(() {
        isLoading = true;
      });

      // Validate fields
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Prepare login data
      Map<String, String> loginData = {
        'email': emailController.text,
        'password': passwordController.text,
      };

      print('Attempting login with email: ${emailController.text}');

      // Make API call
      final response = await http.post(
        Uri.parse(Endpoints.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(loginData),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse response
        final responseData = json.decode(response.body);

        if (responseData['success'] != true) {
          throw responseData['message'] ?? 'Login failed';
        }

        final userData = responseData['data']; // Get the nested data object

        if (userData == null) {
          throw 'Invalid response data';
        }

        print('User data received: $userData');

        // Store user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userData['_id'] ?? '');
        await prefs.setString('userName', userData['name'] ?? '');
        await prefs.setString('userRole', userData['userRole'] ?? '');

        // Verify stored data
        final storedRole = prefs.getString('userRole');
        print('Stored user role: $storedRole');

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Wait for the snackbar to be visible
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        print('Navigating to NavigationBar...');

        // Use GetX navigation with error handling
        try {
          await Get.offAll(() => const Navigationbar());
          print('Navigation completed successfully');
        } catch (navError) {
          print('Navigation error: $navError');
          // Fallback to regular navigation if GetX fails
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const Navigationbar(),
              ),
              (route) => false,
            );
          }
        }
      } else {
        // Handle error
        final errorData = json.decode(response.body);
        throw errorData['message'] ?? 'Login failed: ${response.statusCode}';
      }
    } catch (e) {
      print('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: context.screenHeight,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.imgLogo,
                        width: context.width * 0.7,
                        height: context.height * 0.2,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Health',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                              TextSpan(
                                text: ' Sphere',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Form(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                          hint: AppStrings.emailHint,
                          prefixIcon: Icons.email,
                          isPassword: false,
                          textController: emailController,
                        ),
                        10.heightBox,
                        CustomTextField(
                          hint: AppStrings.passwordHint,
                          isPassword: true,
                          prefixIcon: Icons.lock,
                          textController: passwordController,
                        ),
                        20.heightBox,
                        isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(
                                buttonText: AppStrings.login,
                                onTap: () => loginCall(context),
                              ),
                        20.heightBox,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppStrings.dontHaveAccount.text.make(),
                            8.widthBox,
                            AppStrings.signUp.text
                                .color(Colors.blue)
                                .make()
                                .onTap(() {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupView(),
                                ),
                              );
                            })
                          ],
                        )
                      ],
                    ),
                  ),
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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
