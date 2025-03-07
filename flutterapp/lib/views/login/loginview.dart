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

class LoginView extends StatelessWidget {
  LoginView({super.key});

  // Add controllers for email and password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Add login function
  Future<void> loginCall(BuildContext context) async {
    try {
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

      print('Making login API call');
      print('Request body: ${json.encode(loginData)}');

      // Make API call
      final response = await http.post(
        Uri.parse(Endpoints.login),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(loginData),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Parse response
        final responseData = json.decode(response.body);
        final userData = responseData['data']; // Get the nested data object

        // Store user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', userData['_id'] ?? '');
        await prefs.setString('userName', userData['name'] ?? '');
        await prefs.setString('userRole', userData['userRole'] ?? '');

        print(
            'Stored user data: ID=${userData['_id']}, Name=${userData['name']}, Role=${userData['userRole']}');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to main layout
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Navigationbar(),
          ),
        );
      } else {
        // Handle error
        final errorData = json.decode(response.body);
        throw errorData['message'] ?? 'Login failed';
      }
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
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
                        CustomButton(
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
}
