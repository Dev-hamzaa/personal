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


class LoginView extends StatelessWidget {
  const LoginView({super.key});

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
                        ),
                        10.heightBox,
                        CustomTextField(hint: AppStrings.passwordHint,
                        isPassword: true,
                        prefixIcon: Icons.lock,
                        ),
                        20.heightBox,

                        Align(
                          alignment: Alignment.centerRight,
                          child: AppStrings.forgotPassword.text.make(),
                        ),
                        20.heightBox,
                        CustomButton(
                          buttonText: AppStrings.login,
                          onTap: () async {
                            String role = 'patient'; // This will come from your API
                            
                            // Use only one method to store the role, remove the duplicate
                            await SharedPreferences.getInstance().then((prefs) {
                              prefs.setString('userRole', role);
                            });
                            
                            // Navigate to MainLayout
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Navigationbar(),
                              ),
                            );
                          },
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
