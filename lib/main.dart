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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Color joystickColor = Colors.white;
  Color joystick_iconColor = Colors.blue;
  String connect_buttonText = 'Connect';
  bool connected = false;
  String savedThrottle = '0';
  String savedYaw = '0';
  String savedPitch = '0';
  String savedRoll = '0';
  Socket socket;

  initiateConnection() async {
    setState(() {
      connect_buttonText = 'Connecting...';
    });
    socket = await Socket.connect('10.0.0.1', 80);
    print('Connected.');
    socket.add(utf8.encode('hey'));
    connected = true;
    setState(() {
      connect_buttonText = 'Disconnect';
    });
  }

  closeConnection() async {
    setState(() {
      connect_buttonText = 'Diconnecting...';
    });
    socket.add(utf8.encode('bye'));
    await Future.delayed(const Duration(seconds: 2), (){});
    socket.destroy();
    connected = false;
    setState(() {
      connect_buttonText = 'Connect';
    });
    connect_buttonText = 'Connect';
  }

  send(throttle,yaw,pitch,roll) async {
    socket.add(utf8.encode(throttle + ',' + yaw + ',' + pitch + ',' + roll + '/'));
    //print(throttle + ',' + yaw + ',' + pitch + ',' + roll);
    //print('Sent...' + DateTime.now().toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "UFO Controller",
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('UFO Controller'),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              child: JoystickView(
                interval: Duration(microseconds: 100),
                backgroundColor: joystickColor,
                innerCircleColor: joystickColor,
                iconsColor: joystick_iconColor,
                onDirectionChanged: (double degrees, double distanceFromCenter) {
                  if (connected == true) {
                    double radians = degrees * pi / 180;
                    dynamic throttle = cos(radians) * distanceFromCenter;
                    dynamic yaw = sin(radians) * distanceFromCenter;

                    if (throttle != 0) {
                      throttle = (throttle.toString()).substring(0, 5);
                    } else {
                      throttle = '0';
                    }

                    if (yaw != 0) {
                      yaw = (yaw.toString()).substring(0, 5);
                    } else {
                      yaw = '0';
                    }

                    savedThrottle = throttle;
                    savedYaw = yaw;

                    send(throttle, yaw, savedPitch, savedRoll);
                  }
                },
              ),
              padding: EdgeInsets.only(left: 30),
            ),
            Container(
              child: RaisedButton(
                onPressed: () {
                  if (connected == true) {
                    closeConnection();
                  } else {
                    initiateConnection();
                  }
                },
                textColor: Colors.blue,
                child: Text(connect_buttonText, style: TextStyle(fontSize: 20),),
              )
            ),
            Container(
              child: JoystickView(
                interval: Duration(microseconds: 100),
                backgroundColor: joystickColor,
                innerCircleColor: joystickColor,
                iconsColor: joystick_iconColor,
                onDirectionChanged: (double degrees, double distanceFromCenter) {
                  if (connected == true) {
                    double radians = degrees * pi / 180;
                    dynamic pitch = cos(radians) * distanceFromCenter;
                    dynamic roll = sin(radians) * distanceFromCenter;

                    if (pitch != 0) {
                      pitch = (pitch.toString()).substring(0, 5);
                    } else {
                      pitch = '0';
                    }

                    if (roll != 0) {
                      roll = (roll.toString()).substring(0, 5);
                    } else {
                      roll = '0';
                    }

                    savedPitch = pitch;
                    savedRoll = roll;

                    send(savedThrottle, savedYaw, pitch, roll);
                  }
                },
              ),
              padding: EdgeInsets.only(right: 30),
            )
          ],
        ),
      ),
    );
  }
}