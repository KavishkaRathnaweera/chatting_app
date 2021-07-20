import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/components/reusableButton.dart';

import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String screenId = 'welcome_screen';
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;
  Animation tweenAnimation;

  @override
  void initState() {
    super.initState();

    //this is linear increasing. 0 to 1 with 60 numbers devided evenly.
    //if range 0-60, then values are 1,2,3,......
    controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
      //chance controller value (default 0-1)
      //upperBound: 100.0, //now value 0-100
      //upperBound: 60.0, //used for change flash icon size 0-60
    );

    //this is not linear increasing. controller value range must be between 0-1.
    //then how to use controller value high. :) use controller.value*100 | this equal to 0-100
    animation = CurvedAnimation(parent: controller, curve: Curves.decelerate);

    //this go between 2 values, it can be color,raduis, etc
    tweenAnimation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller); //this go from red to yellow.

    //start ticker and go lower to higher
    controller.forward();
    //go higher to lower
    //controller.reverse(from: 1.0);

    /* loop animation cts by go forward and backward */
    // animation.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     //when forward is finished, completed stated will trigger
    //     controller.reverse(from: 1.0);
    //   } else if (status == AnimationStatus.dismissed) {
    //     //when forward is finished, completed stated will trigger
    //     controller.forward();
    //   }
    // });

    //listen to ticker and can get value
    controller.addListener(() {
      setState(() {});
      //by default, controller.value is between 0.0-1.0
    });
  }

  @override
  void dispose() {
    controller.dispose(); //when screen dispose, controller should dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add changing color from while to red using controller value (0.0-1.0)
      //backgroundColor: Colors.red.withOpacity(controller.value),
      backgroundColor: tweenAnimation.value,
      //backgroundColor: Colors.white,

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'flashLogo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    //animated icon using changing size
                    //height: controller.value, //change linearly
                    //height: animation.value * 60, //change not linearly
                    height: 60.0,
                  ),
                ),
                DefaultTextStyle(
                  style: TextStyle(
                      fontSize: 45.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.black),
                  child: AnimatedTextKit(
                    //loading from 1-100
                    //'${controller.value.toInt()}',
                    animatedTexts: [TypewriterAnimatedText('Flash Chat')],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48.0,
            ),
            ResuableButton(
              buttonColor: Colors.lightBlueAccent,
              onpressed: () {
                Navigator.pushNamed(context, LoginScreen.screenId);
              },
              label: 'login',
            ),
            ResuableButton(
              buttonColor: Colors.lightBlueAccent,
              onpressed: () {
                Navigator.pushNamed(context, RegistrationScreen.screenId);
              },
              label: 'Registration screen',
            ),
          ],
        ),
      ),
    );
  }
}
