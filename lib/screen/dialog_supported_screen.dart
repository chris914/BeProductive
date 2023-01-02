import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timemanagement/util/pomodoro_notifier.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Puts a dialog on top of the screen if a Pomodoro session is in progress.
/// The dialog absorbs every tap event, so user is not able to click on the screen.
class DialogSupportedScreen extends StatefulWidget {
  final Widget screen;

  const DialogSupportedScreen({Key? key, required this.screen})
      : super(key: key);

  @override
  _DialogSupportedScreenState createState() => _DialogSupportedScreenState();
}

class _DialogSupportedScreenState extends State<DialogSupportedScreen> {
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var isRunning = context
          .watch<PomodoroNotifier>()
          .isRunning;
      if (isRunning) {
        return Stack(
          children: [
            ColorFiltered(
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7), BlendMode.darken),
                child: AbsorbPointer(absorbing: true, child: widget.screen)),
            Align(
                alignment: Alignment.center,
                child: _buildOverlayWidget(context)),
          ],
        );
      }

      return widget.screen;
    });
  }

  Widget _buildOverlayWidget(BuildContext context) {
    return AlertDialog(
        title: Row(children: [
          Icon(CupertinoIcons.circle_grid_hex_fill, color: Colors.red),
          Container(
              margin: EdgeInsets.only(left: 8.0),
              child: Text("Pomodoro in progress!",
                  style:
                      GoogleFonts.robotoMono(fontSize: 16, color: Colors.red)))
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Focus on your Pomodoro session, BeProductive can wait for you!",
                style: TextStyle(fontSize: 14)),
          ],
        ));
  }
}
