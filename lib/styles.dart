import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/constants.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle lightRegularText = TextStyle(color: Colors.white);
TextStyle hintRegularText = TextStyle(color: Colors.white70, fontSize: 16, fontFamily: "Oswald");
TextStyle headerText = GoogleFonts.robotoMono(
  letterSpacing: 1.8,
  fontSize: 26,
  color: Colors.white,
);

LinearGradient loginScreenGradient = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  stops: [0, 1],
  colors: [
    Color.fromRGBO(49, 64, 91, 1),
    Color.fromRGBO(55, 60, 95, 1),
  ],
);

LinearGradient pomodoroScreenGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.topRight,
  stops: [0.1, 0.4, 0.7, 1],
  colors: [
    Color.fromRGBO(71, 75, 104, 1),
    Color.fromRGBO(61, 65, 92, 1),
    Color.fromRGBO(57, 60, 87, 1),
    Color.fromRGBO(51, 55, 82, 1),
  ],
);

LinearGradient countDownTimerGradient = LinearGradient(begin: Alignment.topCenter, stops: [
  0.1,
  0.45,
  0.9
], colors: [
  Colors.blueAccent,
  Colors.lightBlue,
  Colors.lightBlueAccent
]);

InputDecoration HintInputDecoration(String hint, IconData icon, VoidCallback onIconPressed) {
  return InputDecoration(
      suffixIcon: IconButton(
        icon: Icon(icon),
        iconSize: 20,
        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
        onPressed: ()  { onIconPressed(); },
      ),
      contentPadding:
      EdgeInsets.fromLTRB(2, 22, 0, 0),
      hintText: "Time");
}

void showInfoDialog(BuildContext context, String type) {
  if (!InfoMap.containsKey(type))
    return;

  showDialog(context: context, builder: (_) {
    return AlertDialog(
        title: Text(type,
            style: GoogleFonts.robotoCondensed()),
        content: Text(InfoMap[type]!),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true)
                  .pop();
            },
            child: Text("Close"),
          )]);
  });
}