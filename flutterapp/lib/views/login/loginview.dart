import 'package:flutter/material.dart';
import 'package:flutterapp/components/custom-button.dart';
import 'package:flutterapp/components/custom-textfield.dart';
import 'package:flutterapp/consts/images.dart';
import 'package:flutterapp/consts/strings.dart';
import 'package:velocity_x/velocity_x.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                AppAssets.imgLogo,
                width: 200,
              ),
            ),
            Expanded(
                flex: 2,
                child: Container(
                  // color: Colors.greenAccent,
                  child: Form(
                      child: Column(
                    children: [
                      CustomTextField(
                        hint: AppStrings.emailHint,
                      ),
                      10.heightBox,
                      CustomTextField(hint: AppStrings.passwordHint),
                      20.heightBox,
                      Align(
                          alignment: Alignment.centerRight,
                          child: AppStrings.forgotPassword.text.make()),
                      20.heightBox,
                      CustomButton(
                        buttonText: AppStrings.login,
                        onTap: () {},
                      ),
                      20.heightBox,
                      Row(
                        children: [],
                      )
                    ],
                  )),
                ))
          ],
        ),
      ),
    );
  }
}
