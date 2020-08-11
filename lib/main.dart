import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './screens/tabScreen.dart';
import './screens/participantsList.dart';
import './providers/event.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (ctx) => Events(),
        child: MaterialApp(
          title: 'Event App',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            accentColor: Colors.lightGreenAccent,
            canvasColor: Colors.yellow[50],
            fontFamily: 'Natural',
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline6: TextStyle(
                    fontSize: 20,
                    fontFamily: 'DreamArranger',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.grey[850],
                  ),
                ),
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routes: {
            '/': (ctx) => TabScreen(0),
            '/EventsList': (ctx) => TabScreen(1),
            '/ParticipantsList': (ctx) => ParticipantsList(),
          },
        ));
  }
}
