import 'package:flutter/material.dart';
import 'package:flutterapp/consts/images.dart';

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
                  color: Colors.greenAccent,
                  // child: Column(
                  //   children: [],
                  // ),
                ))
          ],
        ),
      ),
    );
  }
}
