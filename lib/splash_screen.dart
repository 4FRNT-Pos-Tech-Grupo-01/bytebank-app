import 'package:bytebank_app/home.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Center(
        child: Lottie.asset("assets/animation/bank-animation.json"),
      ),
      nextScreen: MyHomePage(),
      duration: 3500,
      backgroundColor: Colors.black,
      splashIconSize: 400,
    );
  }
}
