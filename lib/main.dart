import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:control_pad/control_pad.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  String savedThrottle = '0';
  String savedYaw = '0';
  String savedPitch = '0';
  String savedRoll = '0';
  Socket socket;

  initiateConnection() async {
    socket = await Socket.connect('10.0.0.1', 80);
    print('Connected.');
    socket.add(utf8.encode('open'));
  }

  send(throttle,yaw,pitch,roll) async {
    socket.add(utf8.encode(throttle + ',' + yaw + ',' + pitch + ',' + roll + '/'));
    print(throttle + ',' + yaw + ',' + pitch + ',' + roll);
    print('Sent...');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "UFO Controller",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('UFO Controller'),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: JoystickView(
                interval: Duration(milliseconds: 50),
                onDirectionChanged: (double degrees, double distanceFromCenter) {
                  double radians = degrees * pi / 180;
                  dynamic throttle = cos(radians) * distanceFromCenter;
                  dynamic yaw = sin(radians) * distanceFromCenter;

                  if (throttle != 0) {
                    throttle = (throttle.toString()).substring(0,5);
                  } else {
                    throttle = '0';
                  }

                  if (yaw != 0) {
                    yaw = (yaw.toString()).substring(0,5);
                  } else {
                    yaw = '0';
                  }

                  savedThrottle = throttle;
                  savedYaw = yaw;

                  send(throttle,yaw,savedPitch,savedRoll);
                },
              ),
              padding: EdgeInsets.only(left: 30),
            ),
            Container(
              child: JoystickView(
                interval: Duration(milliseconds: 50),
                onDirectionChanged: (double degrees, double distanceFromCenter) {
                  double radians = degrees * pi / 180;
                  dynamic pitch = cos(radians) * distanceFromCenter;
                  dynamic roll = sin(radians) * distanceFromCenter;

                  if (pitch != 0) {
                    pitch = (pitch.toString()).substring(0,5);
                  } else {
                    pitch = '0';
                  }

                  if (roll != 0) {
                    roll = (roll.toString()).substring(0,5);
                  } else {
                    roll = '0';
                  }

                  savedPitch = pitch;
                  savedRoll = roll;

                  send(savedThrottle,savedYaw,pitch,roll);
                },
              ),
              padding: EdgeInsets.only(right: 30),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: initiateConnection,
          child: Icon(Icons.call),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}